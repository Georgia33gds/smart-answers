status :draft
section_slug "money-and-tax"
subsection_slug "tax"
satisfies_need "2013"

maximum_number_of_days_in_month = 31
calculator = Calculators::MinimumWageCalculator.new

# Q1
multiple_choice :what_would_you_like_to_check? do
  option "current_payment" => :are_you_an_apprentice?
  option "past_payment" => :past_payment_year?
  save_input_as :current_or_past_payments
end

# Q1A
multiple_choice :past_payment_year? do

  option "2011"
  option "2010"
  option "2009"
  option "2008"
  option "2007"
  option "2006"
  option "2005" 
  
  save_input_as :payment_year
  
  next_node :were_you_an_apprentice?
  
end

# Q2
multiple_choice :are_you_an_apprentice? do
  save_input_as :is_apprentice
  option "no" => :how_old_are_you?
  option "apprentice_under_19" => :how_often_do_you_get_paid?
  option "apprentice_over_19" => :how_often_do_you_get_paid?
end

# Q2 Past
multiple_choice :were_you_an_apprentice? do
  save_input_as :was_apprentice
  option "no" => :how_old_were_you?
  option "apprentice_under_19" => :how_often_did_you_get_paid?
  option "apprentice_over_19" => :how_often_did_you_get_paid?
end

# Q3
value_question :how_old_are_you? do  
  save_input_as :age
  next_node :how_often_do_you_get_paid?
end

# Q3 Past
value_question :how_old_were_you? do  
  save_input_as :age
  next_node :how_often_did_you_get_paid?
end

# Q4
value_question :how_often_do_you_get_paid? do 
  save_input_as :pay_frequency
  next_node :how_many_hours_do_you_work?
end

# Q4 Past
value_question :how_often_did_you_get_paid? do 
  save_input_as :pay_frequency
  next_node :how_many_hours_did_you_work?
end

# Q5
value_question :how_many_hours_do_you_work? do
  save_input_as :basic_hours
  next_node :how_much_are_you_paid_during_pay_period?
end

# Q5 Past
value_question :how_many_hours_did_you_work? do
  save_input_as :basic_hours
  next_node :how_much_were_you_paid_during_pay_period?
end

# Q6
value_question :how_much_are_you_paid_during_pay_period? do
  save_input_as :total_basic_pay
  
  calculate :basic_hourly_rate do
    (responses.last.to_f / basic_hours.to_f).round(2)  
  end
  
  next_node :how_many_hours_overtime_do_you_work?
end

# Q6 Past
value_question :how_much_were_you_paid_during_pay_period? do
  save_input_as :total_basic_pay
  
  calculate :basic_hourly_rate do
    (responses.last.to_f / basic_hours.to_f).round(2)  
  end
  
  next_node :how_many_hours_overtime_did_you_work?
end

# Q7
value_question :how_many_hours_overtime_do_you_work? do
  save_input_as :overtime_hours
  
  calculate :total_hours do
    (basic_hours.to_f + responses.last.to_f).round(2)  
  end
  
  next_node do |response|
    if response.to_i == 0
      :is_provided_with_accommodation?
    else
      :what_is_overtime_pay_per_hour?
    end
  end
end

# Q7 Past
value_question :how_many_hours_overtime_did_you_work? do
  save_input_as :overtime_hours
  
  calculate :total_hours do
    (basic_hours.to_f + responses.last.to_f).round(2)  
  end
  
  calculate :historical_entitlement do
    historical_rate = calculator.minimum_hourly_rate(age.to_i, (was_apprentice != 'no'), payment_year)
    (historical_rate * total_hours).round(2)
  end
  
  next_node do |response|
    if response.to_i == 0
      :was_provided_with_accommodation?
    else
      :what_was_overtime_pay_per_hour?
    end
  end
end

# Q8
value_question :what_is_overtime_pay_per_hour? do
  save_input_as :overtime_rate
  
  calculate :total_overtime_pay do
    overtime_hourly_rate = responses.last.to_f
    # Calculate overtime rate as the lower of the two basic/overtime rates.
    overtime_hourly_rate = basic_hourly_rate if (overtime_hourly_rate < basic_hourly_rate)
    (overtime_hourly_rate * overtime_hours.to_f).round(2)
  end
  
  calculate :total_basic_pay do
    (total_overtime_pay + total_basic_pay.to_f).round(2)
  end
  
  calculate :total_hourly_rate do
    (total_basic_pay / total_hours).round(2)
  end
  
  calculate :minimum_hourly_rate do
    calculator.minimum_hourly_rate(age.to_i, (is_apprentice != 'no'))
  end
  
  calculate :getting_minimum_wage do
    (total_hourly_rate > minimum_hourly_rate ? "are" : "aren't")
  end
  
  next_node :is_provided_with_accommodation?
end

# Q8 Past
value_question :what_was_overtime_pay_per_hour? do
  save_input_as :overtime_rate
  
  calculate :total_overtime_pay do
    overtime_hourly_rate = responses.last.to_f
    # Calculate overtime rate as the lower of the two basic/overtime rates.
    overtime_hourly_rate = basic_hourly_rate if (overtime_hourly_rate < basic_hourly_rate)
    (overtime_hourly_rate * overtime_hours.to_f).round(2)
  end
  
  calculate :total_basic_pay do
    (total_overtime_pay + total_basic_pay.to_f).round(2)
  end
  
  calculate :total_hourly_rate do
    (total_basic_pay / total_hours).round(2)
  end
  
  next_node :was_provided_with_accommodation?
end

# Q9
multiple_choice :is_provided_with_accommodation? do
  option "no" => :current_payment
  option "yes_free" => :current_accommodation_usage?
  option "yes_charged" => :current_accommodation_charge?
end

# Q9 Past
multiple_choice :was_provided_with_accommodation? do
  option "no" => :past_payment_results
  option "yes_free" => :past_accommodation_usage?
  option "yes_charged" => :past_accommodation_charge?
end

# Q10
value_question :current_accommodation_charge? do
  save_input_as :accommodation_charge
  next_node :current_accommodation_usage?
end

# Q10 Past
value_question :past_accommodation_charge? do
  save_input_as :accommodation_charge
  next_node :past_accommodation_usage?
end

# Q11
value_question :current_accommodation_usage? do
  
  calculate :total_basic_pay do
    usage = responses.last.to_i # TODO: Check this input is full days only?
    accommodation_adjustment = calculator.accommodation_adjustment(accommodation_charge.to_f, usage)
    total_basic_pay.to_f + accommodation_adjustment  
  end
  
  calculate :total_hourly_rate do
    (total_basic_pay / total_hours).round(2)
  end
  
  next_node :current_payment_over
end

# Q11 Past
value_question :past_accommodation_usage? do
  
  calculate :total_basic_pay do
    usage = responses.last.to_i # TODO: Check this input is full days only?
    accommodation_adjustment = calculator.accommodation_adjustment(accommodation_charge.to_f, usage)
    total_basic_pay.to_f + accommodation_adjustment  
  end
  
  calculate :total_hourly_rate do
    (total_basic_pay / total_hours).round(2)
  end
  
  next_node :past_payment_over
end

outcome :current_payment
outcome :past_payment
