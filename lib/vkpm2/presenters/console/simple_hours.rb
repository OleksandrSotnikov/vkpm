# frozen_string_literal: true

module VKPM2
  module Presenters
    module Console
      class SimpleHours
        attr_reader :year, :month, :report_entries, :holidays, :breaks, :pastel

        def initialize(year:, month:, report_entries:, holidays:, breaks:, pastel: Adapters::Pastel.new)
          @year = year
          @month = month
          @report_entries = report_entries
          @holidays = holidays
          @breaks = breaks
          @pastel = pastel
        end

        def to_s
          <<~TEXT
            #{pastel.bold("# #{month_name} #{year}")}
            #{date_range.map(&method(:format_date_row)).join("\n")}

            Reported hours: #{human_readable_time(all_reported_minutes)}
          TEXT
        end

        private

        def month_name
          Date::MONTHNAMES[month]
        end

        def format_date_row(date)
          Line.new(date, report_entries, holidays, breaks, pastel:).to_s
        end

        def date_range
          start_of_month = Date.new(year, month, 1)
          end_of_month = start_of_month.end_of_month

          (start_of_month..end_of_month)
        end

        def all_reported_minutes
          report_entries.map { |entry| entry.duration.in_minutes }.sum
        end

        def human_readable_time(minutes)
          [[60, :m], [Float::INFINITY, :h]].map do |count, name|
            minutes, number = minutes.divmod(count)
            "#{number.to_i}#{name}" unless number.to_i.zero?
          end.compact.reverse.join
        end

        class Line
          attr_reader :date, :entries, :holidays, :breaks, :pastel

          def initialize(date, entries, holidays, breaks, pastel:)
            @date = date
            @entries = entries
            @holidays = holidays
            @breaks = breaks
            @pastel = pastel
          end

          def to_s
            line = [
              formatted_entries,
              formatted_holidays,
              formatted_break,
              formatted_missing_report,
              formatted_need_to_report
            ].reject(&:blank?).join(' ')

            "#{formatted_date} #{formatted_time_spent_at_date}: #{line}"
          end

          private

          def formatted_date
            date.strftime('%a %d')
          end

          def formatted_time_spent_at_date
            format('(%-6s)', human_readable_time(minutes_spent_at_date))
          end

          def minutes_spent_at_date
            day_entries.map { |entry| entry.duration.in_minutes }.sum
          end

          def formatted_holidays
            today_holidays.map(&:name).join(', ')
          end

          def today_holidays
            holidays.select { |holiday| holiday.date == date }
          end

          def day_entries
            @day_entries ||= entries.select { |entry| entry.task.date == date }
          end

          def formatted_entries
            day_entries.map(&method(:format_entry)).join(' ')
          end

          def format_entry(entry)
            size = (entry.duration.in_minutes / 10).to_i

            block_text = "#{human_readable_time(entry.duration.in_minutes)}, #{entry.project.name}"
            block_format = format("%-#{size}.#{size}s", block_text)
            pastel.underscore(block_format)
          end

          def formatted_missing_report
            'Forgot to report?' if missing_report?
          end

          def missing_report?
            date < Date.today &&
              day_entries.empty? &&
              today_holidays.empty? &&
              !having_a_break? &&
              !date.saturday? &&
              !date.sunday?
          end

          def formatted_break
            'Break' if having_a_break?
          end

          def having_a_break?
            breaks.any? { |a_break| a_break.active?(date) }
          end

          def formatted_need_to_report
            'Need to report?' if need_to_report?
          end

          def need_to_report?
            date == Date.today &&
              (day_entries.empty? || minutes_spent_at_date < 8.hours.in_minutes) &&
              today_holidays.empty? &&
              !having_a_break? &&
              !date.saturday? &&
              !date.sunday?
          end

          def human_readable_time(minutes)
            [[60, :m], [Float::INFINITY, :h]].map do |count, name|
              minutes, number = minutes.divmod(count)
              "#{number.to_i}#{name}" unless number.to_i.zero?
            end.compact.reverse.join
          end
        end
      end
    end
  end
end
