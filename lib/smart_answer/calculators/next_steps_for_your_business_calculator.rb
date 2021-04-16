require "companies_house/client"

# ======================================================================
# Allows access to the quesion answers provides custom validations
# and calculations, and other supporting methods.
# ======================================================================

class Business
  attr_accessor :company_registration_number,
                :estimated_annual_turnover,
                :employer,
                :import_goods,
                :export_goods,
                :sell_goods_online,
                :needs_financial_support,
                :vat_registration_number,
                :has_non_domestic_property
end

module SmartAnswer::Calculators
  class NextStepsForYourBusinessCalculator
    RESULT_DATA = YAML.load_file(Rails.root.join("config/smart_answers/next_steps_for_your_business.yml")).freeze

    def self.companies_house_client
      @companies_house_client ||= CompaniesHouse::Client.new(api_key: ENV["COMPANIES_HOUSE_API_KEY"])
    end

    attr_accessor :crn,
                  :annual_turnover,
                  :employ_someone,
                  :business_intent,
                  :business_support,
                  :business_premises,
                  :business

    def initialize
      @business = Business.new
    end

    def grouped_results
      results = RESULT_DATA.select do |result|
        p result["title"]
        eligibility_rule = RULES[result["id"].to_sym]
        p eligibility_rule
        if eligibility_rule
          p eligibility_rule.call(business)
          eligibility_rule.call(business)
        else
          true
        end
      end

      results.group_by { |result| result["section_name"] }
    end

    def company_exists?
      self.class.companies_house_client.company(crn).present?
    rescue CompaniesHouse::NotFoundError
      false
    end

    def company_name
      profile = self.class.companies_house_client.company(crn)
      profile["company_name"]
    rescue CompaniesHouse::APIError
      # Will try best attempt at getting company name, but not necessary for flow
    end

    RULES = {
      r13: lambda { |business|
        business.estimated_annual_turnover > 85_000
      },
      r14: lambda { |business|
        business.estimated_annual_turnover > 85_000
      },
      r15: lambda { |business|
        business.employer
      },
      r16: lambda { |business|
        business.needs_financial_support
      },
      r17: lambda { |business|
        business.needs_financial_support
      },
      r18: lambda { |business|
        business.needs_financial_support
      },
      r19: lambda { |business|
        business.needs_financial_support
      },
      r20: lambda { |business|
        business.has_non_domestic_property
      },
      r21: lambda { |business|
        business.has_non_domestic_property
      },
      r22: lambda { |business|
        business.employer
      },
      r24: lambda { |business|
        business.has_non_domestic_property
      },
      r25: lambda { |business|
        business.import_goods
      },
      r26: lambda { |business|
        business.export_goods
      },
      r27: lambda { |business|
        business.sell_goods_online
      },
      r29: lambda { |business|
        business.estimated_annual_turnover < 85_000
      },
    }
  end
end
