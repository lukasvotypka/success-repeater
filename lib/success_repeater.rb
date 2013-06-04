require "success_repeater/version"

module SuccessRepeater
  class Base
    attr_accessor :max_hours_run

    def initialize(options={})
      options = options.reverse_merge(
          :max_hours_run => 20
      )
      @max_hours_run = options[:max_hours_run]
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
          hours_run = ((DateTime.now - start_at) * 24).to_i
          if hours_run > @max_hours_run || Rails.env=="development"
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
      Rails.logger.error_with_exception_param("Succ repeater error", e)
      sleep(60*10) # 10 minutes
    end
  end
end
