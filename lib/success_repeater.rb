require "success_repeater/version"
require 'active_support/core_ext'

module SuccessRepeater
  class Base
    attr_accessor :max_seconds_run, :sleep_time

    # @param [Hash{Symbol=>Object}] options
    # == Example
    # SuccessRepeater::Base.new(:max_seconds_run => 20.hours.to_i,
    #   :sleep_time => 10.minutes.to_i)
    def initialize(options={})
      options = options.reverse_merge(
          :max_seconds_run => 72000, # 20 hours
          :sleep_time => 600 # 10minutes
      )
      @max_seconds_run = options[:max_seconds_run]
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
      err_msg = "Succ repeater error #{e.backtrace.join("\n")}"
      Rails.logger.error(err_msg) if defined?(Rails.logger.error)
      puts err_msg
      sleep(@sleep_time)
    end
  end
end
