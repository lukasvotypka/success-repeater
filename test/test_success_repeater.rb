require 'test/unit'
require 'success_repeater'
require 'test-unit'

class SuccessRepeaterBaseTest < Test::Unit::TestCase

  def test_sleep
    max_run = 10
    t = SuccessRepeater::Base.new(:max_seconds_run=>max_run,
      :sleep_time => 1)
    start_at = DateTime.now
    times = 0
    t.run do
      times += 1
      error_cmd
    end
    finish_at = DateTime.now
    exec_time = finish_at.to_i - start_at.to_i
    assert(exec_time > max_run)
    assert(exec_time < max_run + 4)
    assert_equal(11, times)
  end
end