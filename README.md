
# SuccessRepeater

Rerun yield code if exception is raised.

## Installation

Add this line to your application's Gemfile:

    gem 'success_repeater'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install success_repeater

## Usage

    require 'success_repeater'
    transaction = SuccessRepeater::Base.new(:max_seconds_run=>10.minutes.to_i,
        :sleep_time=>30.seconds.to_i)
    transaction.run do
      # your code
      puts "run your code. If error was raised then process sleeps to 30seconds a run your code again."
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request