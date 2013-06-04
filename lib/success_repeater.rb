require "success_repeater/version"

module SuccessRepeater
  class Base
    attr_accessor :max_seconds_run, :sleep_time

    def initialize(options={})
      options = options.reverse_merge(
          :max_seconds_run => 20.hours.to_i,
          :sleep_time => 10.minutes.to_i
      )
      @max_hours_run = options[:max_seconds_run]
      @sleep_time = options[:sleep_time]
    end

    def run(&block)
      done = false
      start_at = DateTime.now
      error = nil
      while !done
        begin
          if defined?(ActiveRecord::Base.transaction)
            # do it in transaction
            ActiveRecord::Base.transaction do
              block.call
            end
          else
            block.call
          end
          done = true
        rescue => e
          on_failure(e)
          # prevent blocking cron next day job
          seconds_run = ((DateTime.now - start_at) * 24 * 60 *60).to_i
          if seconds_run > @max_seconds_run
            done = true
            error = e
          else
            done = false
          end

        end
      end

      unless error.nil?
        on_failure(error)
      end
    end

    def on_failure(e)
      ExceptionNotifier::Notifier.background_exception_notification(e) if defined?(ExceptionNotifier::Notifier.background_exception_notification)
      Rails.logger.error("Succ repeater error #{e.backtrace.join("\n")}")
      sleep(sleep_time)
    end
  end
end
