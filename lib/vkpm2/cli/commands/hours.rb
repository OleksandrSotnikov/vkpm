# frozen_string_literal: true

module VKPM2
  module CLI
    module Commands
      class Hours < Thor
        desc 'show', 'Show hours'

        option :year, type: :numeric, default: Time.now.year
        option :month, type: :numeric, default: Time.now.month
        def show
          result = Organizers::GetReportedEntries.call(report_year: options[:year], report_month: options[:month])
          raise Error, result.error if result.failure?

          puts Presenters::Console::SimpleHours.new(year:, month:, report_entries: result.reported_entries)
        end

        private

        def year
          options[:year]
        end

        def month
          options[:month]
        end
      end
    end
  end
end
