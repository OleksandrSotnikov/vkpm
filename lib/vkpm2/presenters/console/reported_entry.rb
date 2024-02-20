# frozen_string_literal: true

module VKPM2
  module Presenters
    module Console
      class ReportedEntry
        attr_reader :entry

        def initialize(entry)
          @entry = entry
        end

        def to_s
          <<~STR
            Reported #{duration} (#{from} - #{to}) of #{activity} time.
            Completeness: #{completeness}

            ##{entry.id}: #{entry.task.name}: #{entry.task.description}
          STR
        end

        private

        def duration
          human_readable_time(entry.duration.in_minutes)
        end

        def from
          entry.task.starts_at.strftime('%H:%M')
        end

        def to
          entry.task.ends_at.strftime('%H:%M')
        end

        def activity
          entry.activity.name.downcase
        end

        def completeness
          "#{entry.task.status}%"
        end

        def human_readable_time(minutes)
          [[60, :minutes], [Float::INFINITY, :hours]].map do |count, name|
            minutes, number = minutes.divmod(count)
            "#{number.to_i} #{number > 1 ? name : name.to_s.chomp('s')}" unless number.zero?
          end.compact.reverse.join(' and ')
        end
      end
    end
  end
end
