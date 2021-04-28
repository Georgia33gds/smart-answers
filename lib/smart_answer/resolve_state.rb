module SmartAnswer
  class ResolveState
    def initialize(flow)
      @flow = flow
    end

    def from_response_store(response_store, requested_node = nil)
      forwarding_responses = flow.response_store == :session ? {} : response_store.all
      state = start_state(forwarding_responses)
      loop do
        node_name = flow.node(state.current_node).name.to_s
        return state unless response_store.has?(node_name)

        response = response_store.get(node_name)
        return current_state(state, response) if node_name == requested_node

        new_state = next_state(state, response)
        return new_state if new_state.error
        return new_state if flow.node(new_state.current_node).outcome?

        state = new_state
      end
    end

    def from_params(params)
      responses = params[:responses].to_s.split("/")

      state = responses.inject(start_state) do |memo, response|
        return memo if memo.error

        next_state(memo, response)
      end

      if params[:next]
        next_state(state, params[:response])
      elsif params[:previous_response]
        current_state(state, params[:previous_response])
      else
        state
      end
    end

  private

    attr_reader :flow

    def start_state(forwarding_responses = {})
      State.new(flow.questions.first.name,
                forwarding_responses: forwarding_responses).freeze
    end

    def next_state(state, response)
      flow.node(state.current_node).transition(state, response)
    rescue BaseStateTransitionError => e
      error_state(state, response, e)
    end

    def current_state(state, response)
      # check for errors by seeing if we can reach next state
      flow.node(state.current_node).transition(state, response)

      state.dup.tap do |new_state|
        new_state.current_response = response
        new_state.freeze
      end
    rescue BaseStateTransitionError => e
      error_state(state, response, e)
    end

    def error_state(state, response, error)
      GovukError.notify(error) if error.is_a?(LoggedError)

      state.dup.tap do |new_state|
        new_state.error = error.message
        new_state.current_response = response
        new_state.freeze
      end
    end
  end
end
