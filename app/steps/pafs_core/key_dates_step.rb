# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class KeyDatesStep < BasicStep
    delegate :start_outline_business_case_month, :start_outline_business_case_month=,
            :start_outline_business_case_year, :start_outline_business_case_year=,
            :award_contract_month, :award_contract_month=,
            :award_contract_year, :award_contract_year=,
            :start_construction_month, :start_construction_month=,
            :start_construction_year, :start_construction_year=,
            :ready_for_service_month, :ready_for_service_month=,
            :ready_for_service_year, :ready_for_service_year=, to: :project

    validate :key_dates_are_present_and_correct

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :funding_sources
        true
      else
        false
      end
    end

    def previous_step
      :financial_year
    end

    def step
      @step ||= :key_dates
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:key_dates_step).permit(
        :start_outline_business_case_month, :start_outline_business_case_year,
        :award_contract_month, :award_contract_year,
        :start_construction_month, :start_construction_year,
        :ready_for_service_month, :ready_for_service_year)
    end

    def key_dates_are_present_and_correct
      dates_are_present_and_in_range
      return if errors.any?
      dates_are_in_order
    end

    def dates_are_present_and_in_range
      [:start_outline_business_case_month,
       :award_contract_month,
       :start_construction_month,
       :ready_for_service_month,
       :start_outline_business_case_year,
       :award_contract_year,
       :start_construction_year,
       :ready_for_service_year].each do |attr|
         range = attr.to_s.end_with?("month") ? 1..12 : 2000..2099
         validate_date_component(attr, range)
       end
    end

    def validate_date_component(attr, range)
      val = send(attr)
      if val.blank?
        errors.add(attr, "cannot be blank")
      else
        m = val.to_i
        unless range.include?(m) && (m.to_s == val.to_s)
          errors.add(attr, "must be in the range #{range.min} to #{range.max}")
        end
      end
    end

    def dates_are_in_order
      dt1 = Date.new(start_outline_business_case_year, start_outline_business_case_month, 1)
      dt2 = Date.new(award_contract_year, award_contract_month, 1)
      dt3 = Date.new(start_construction_year, start_construction_month, 1)
      dt4 = Date.new(ready_for_service_year, ready_for_service_month, 1)

      if dt4 < dt3
        # error
        errors.add(:ready_for_service_year, "can't be earlier than start of construction date")
      elsif dt3 < dt2
        # error
        errors.add(:start_construction_year, "can't be earlier than award of contract date")
      elsif dt2 < dt1
        # error
        errors.add(:award_contract_year, "can't be earlier than the start of the outline business case date")
      end
    end
  end
end
