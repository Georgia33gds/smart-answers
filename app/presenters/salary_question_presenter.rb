class SalaryQuestionPresenter < QuestionPresenter
  include SmartAnswer::FormattingHelper

  def response_label(value)
    format_salary(SmartAnswer::Salary.new(value))
  end

  def amount
    if response_for_current_question
      response_for_current_question[:amount]
    elsif flow_presenter.current_state.current_response.is_a?(Hash)
      flow_presenter.current_state.current_response[:amount]
    end
  end

  def period
    if response_for_current_question
      response_for_current_question[:period]
    elsif flow_presenter.current_state.current_response.is_a?(Hash)
      flow_presenter.current_state.current_response[:period]
    end
  end
end
