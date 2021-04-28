require_relative "../test_helper"

module SmartAnswer
  class ResolveStateTest < ActiveSupport::TestCase
    setup do
      @flow = SmartAnswer::Flow.new do
        radio :x do
          option :yes
          option :no
          next_node do |response|
            case response
            when "yes" then outcome :y
            when "no" then question :a
            end
          end
        end

        radio :y do
          option :yes
          option :no
          next_node do |response|
            case response
            when "yes" then outcome :a
            when "no" then outcome :b
            end
          end
        end
        outcome :a
        outcome :b
      end

      @resolve_state = ResolveState.new(@flow)
    end

    context "#from_response_store" do
      should "return the state for the first question when there are no responses" do
        response_store = ResponseStore.new(responses: {})
        state = @resolve_state.from_response_store(response_store)

        assert_equal :x, state.current_node
        assert_empty state.accepted_responses
        assert_nil state.current_response
      end

      should "return the state for the next question when there are valid answers" do
        response_store = ResponseStore.new(responses: { "x" => "yes" })
        state = @resolve_state.from_response_store(response_store)

        assert_equal :y, state.current_node
        assert_equal ({ x: "yes" }), state.accepted_responses
        assert_nil state.current_response
      end

      should "return an error state for the current question when an answer is invalid" do
        response_store = ResponseStore.new(responses: { "x" => "yes", "y" => "invalid" })
        state = @resolve_state.from_response_store(response_store)

        assert_equal :y, state.current_node
        assert_equal ({ x: "yes" }), state.accepted_responses
        assert_equal "invalid", state.current_response
        assert state.error.present?
      end

      should "return an outcome state when all questions are answered" do
        response_store = ResponseStore.new(responses: { "x" => "yes", "y" => "no" })
        state = @resolve_state.from_response_store(response_store)

        assert_equal :b, state.current_node
        assert_equal ({ x: "yes", y: "no" }), state.accepted_responses
        assert_nil state.current_response
      end

      should "return an particular node if one is requested" do
        response_store = ResponseStore.new(responses: { "x" => "yes", "y" => "no" })
        state = @resolve_state.from_response_store(response_store, "y")

        assert_equal :y, state.current_node
        assert_equal ({ x: "yes" }), state.accepted_responses
        assert_equal "no", state.current_response
      end

      should "maintain all responses for forwading on a non-session response_store" do
        @flow.response_store(:query_parameters)
        responses = { "x" => "yes", "y" => "no", "z" => "yes" }
        response_store = ResponseStore.new(responses: responses)

        state = @resolve_state.from_response_store(response_store)

        assert_equal responses, state.forwarding_responses
      end

      should "not maintain forwarding responses on a session response_store" do
        @flow.response_store(:session)
        responses = { "x" => "yes", "y" => "no", "z" => "yes" }
        response_store = ResponseStore.new(responses: responses)

        state = @resolve_state.from_response_store(response_store)

        assert_empty state.forwarding_responses
      end
    end

    context "#from_params" do
      should "return the state for the first question when there are no responses" do
        state = @resolve_state.from_params({ responses: "" })

        assert_equal :x, state.current_node
        assert_empty state.accepted_responses
        assert_nil state.current_response
      end

      should "establish the state for the next question when a valid answer is given" do
        state = @resolve_state.from_params({ responses: "", next: "1", response: "yes" })

        assert_equal :y, state.current_node
        assert_equal ({ x: "yes" }), state.accepted_responses
        assert_nil state.current_response
      end

      should "return the state for the next question when an answer is in the path" do
        state = @resolve_state.from_params({ responses: "yes" })

        assert_equal :y, state.current_node
        assert_equal ({ x: "yes" }), state.accepted_responses
        assert_nil state.current_response
      end

      should "return an error state for the current question when an answer is invalid" do
        state = @resolve_state.from_params({ responses: "yes/invalid" })

        assert_equal :y, state.current_node
        assert_equal ({ x: "yes" }), state.accepted_responses
        assert_equal "invalid", state.current_response
        assert state.error.present?
      end

      should "return an outcome state when all questions are answered" do
        state = @resolve_state.from_params({ responses: "yes/no" })

        assert_equal :b, state.current_node
        assert_equal ({ x: "yes", y: "no" }), state.accepted_responses
        assert_nil state.current_response
      end

      should "determine the current response from a previous_response parameter" do
        state = @resolve_state.from_params({ responses: "yes", previous_response: "no" })

        assert_equal :y, state.current_node
        assert_equal ({ x: "yes" }), state.accepted_responses
        assert_equal "no", state.current_response
      end
    end
  end
end
