module PafsCore
  module SpreadsheetBuilderService
    class ProcessSixYearTotals
      def process_funding_six_year_totals(record)
        totals_hash = {}
        funding_sources = %w(gia total)
        funding_sources.each do |fs|
          total = process_six_year_total(record["#{fs}_list"]) if record["#{fs}_list"].present?
          symbol = "#{fs}_six_year_total".to_sym
          totals_hash[symbol] = total
        end

        other_funding_sources = %w(public private ea)

        combined_total = 0
        other_funding_sources.each do |ofs|
          if record["#{ofs}_list"].present?
            total = process_six_year_total(record["#{ofs}_list"])
            combined_total += total.to_i
          end
        end
        combined_total = nil if combined_total.zero?
        totals_hash[:contributions_six_year_total] = combined_total

        totals_hash
      end

      def process_households_six_year_totals(record)
        keys = %w(
        flood_households
        coastal_households
        )

        total = 0

        keys.each do |key|
          total += process_six_year_total(record[key]) if record[key].present?
        end

        total = nil if total.zero?
        total
      end

      def process_six_year_total(array)
        array = JSON.parse(array)
        total = 0
        array.each { |e| total += e["f2"].to_i if e["f1"].to_i < 2021 }
        total
      end
    end
  end
end
