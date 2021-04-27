require "ostruct"

module SmartAnswer
  class Flow
    class NonSessionBasedFlow < StandardError; end

    attr_reader :nodes
    attr_writer :status

    def self.build
      flow = new
      flow.define
      flow
    end

    def initialize(&block)
      @nodes = []
      status(:draft)
      instance_eval(&block) if block_given?
    end

    def append(flow)
      flow.nodes.each do |node|
        node.flow = self
        add_node(node)
      end
    end

    def content_id(id = nil)
      @content_id = id unless id.nil?
      @content_id
    end

    def name(name = nil)
      @name = name unless name.nil?
      @name
    end

    def response_store(response_store = nil)
      @response_store = response_store unless response_store.nil?
      @response_store
    end

    def use_escape_button(use_escape_button) # rubocop:disable Style/TrivialAccessors
      @use_escape_button = use_escape_button
    end

    def use_escape_button?
      raise NonSessionBasedFlow, "This flow is not session-based" unless response_store == :session

      ActiveModel::Type::Boolean.new.cast(@use_escape_button)
    end

    def show_escape_link?
      response_store == :session && use_escape_button?
    end

    def hide_previous_answers_on_results_page(hide_previous_answers_on_results_page) # rubocop:disable Style/TrivialAccessors
      @hide_previous_answers_on_results_page = hide_previous_answers_on_results_page
    end

    def hide_previous_answers_on_results_page?
      ActiveModel::Type::Boolean.new.cast(@hide_previous_answers_on_results_page)
    end

    def status(potential_status = nil)
      if potential_status
        raise Flow::InvalidStatus unless %i[published draft].include? potential_status

        @status = potential_status
      end

      @status
    end

    def radio(name, &block)
      add_node Question::Radio.new(self, name, &block)
    end

    def country_select(name, options = {}, &block)
      add_node Question::CountrySelect.new(self, name, options, &block)
    end

    def date_question(name, &block)
      add_node Question::Date.new(self, name, &block)
    end

    def value_question(name, options = {}, &block)
      add_node Question::Value.new(self, name, options, &block)
    end

    def money_question(name, &block)
      add_node Question::Money.new(self, name, &block)
    end

    def salary_question(name, &block)
      add_node Question::Salary.new(self, name, &block)
    end

    def checkbox_question(name, &block)
      add_node Question::Checkbox.new(self, name, &block)
    end

    def postcode_question(name, &block)
      add_node Question::Postcode.new(self, name, &block)
    end

    def outcome(name, &block)
      add_node Outcome.new(self, name, &block)
    end

    def outcomes
      @nodes.select(&:outcome?)
    end

    def questions
      @nodes.select(&:question?)
    end

    def node_exists?(node_or_name)
      @nodes.any? { |n| n.name == node_or_name.to_sym }
    end

    def node(node_or_name)
      @nodes.find { |n| n.name == node_or_name.to_sym } || raise("Node '#{node_or_name}' does not exist")
    end

    def start_node
      Node.new(self, name.underscore.to_sym)
    end

    def start_state
      State.new(questions.first.name).freeze
    end

    def resolve_state_from_response_store(response_store, requested_node = nil)
      state = start_state
      loop do
        node_name = node(state.current_node).name.to_s
        return state unless response_store.has?(node_name)

        response = response_store.get(node_name)
        return current_state(state, response) if node_name == requested_node

        new_state = next_state(state, response)
        return new_state if new_state.error
        return new_state if node(new_state.current_node).outcome?

        state = new_state
      end
    end

    def resolve_state_from_params(params)
      responses = params[:responses].to_s.split("/")

      state = responses.inject(start_state) do |current_state, response|
        return current_state if current_state.error

        next_state(current_state, response)
      end

      if params[:next]
        next_state(state, params[:response])
      elsif params[:previous_response]
        current_state(state, params[:previous_response])
      else
        state
      end
    end

    def next_state(state, response)
      node(state.current_node).transition(state, response)
    rescue BaseStateTransitionError => e
      error_state(state, response, e)
    end

    def current_state(state, response)
      # check for errors by seeing if we can reach next state
      node(state.current_node).transition(state, response)

      state.dup.tap do |new_state|
        new_state.current_response = response
        new_state.freeze
      end
    rescue BaseStateTransitionError => e
      error_state(state, response, e)
    end

    class InvalidStatus < StandardError; end

  private

    def error_state(state, response, error)
      GovukError.notify(error) if error.is_a?(LoggedError)

      state.dup.tap do |new_state|
        new_state.error = error.message
        new_state.current_response = response
        new_state.freeze
      end
    end

    def add_node(node)
      raise "Node #{node.name} already defined" if node_exists?(node)

      @nodes << node
    end
  end
end
