class DateQuestionPresenter < QuestionPresenter
  delegate :default_day,
           :default_month,
           :default_year,
           to: :@node

  def response_label(value)
    if only_display_day_and_month?(value)
      value.strftime("%e %B")
    else
      value.strftime("%e %B %Y")
    end
  end

  def selected(field)
    if response_for_current_question
      response_for_current_question[field]
    elsif flow_presenter.current_state.current_response.is_a?(Hash)
      flow_presenter.current_state.current_response[field]
    end
  end

private

  def only_display_day_and_month?(value)
    value.year.zero?
  end
end
