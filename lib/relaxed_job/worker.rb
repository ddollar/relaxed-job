require 'benchmark'
require 'couchrest'
require 'relaxed_job'

class RelaxedJob::Worker

  SLEEP = 5

  attr_reader :queue
  attr_reader :options

  def initialize(couchrest_url, options={})
    @queue   = RelaxedJob::Queue.new(couchrest_url)
    @options = options
  end

  def name
    "testname"
  end

  def start(options={})
    say "*** Starting job worker #{queue.worker_name}"

    trap('TERM') { say 'Exiting...'; $exit = true }
    trap('INT')  { say 'Exiting...'; $exit = true }

    sleep_for = options[:sleep] || DEFAULT_SLEEP

    loop do
      result = nil

      realtime = Benchmark.realtime do
        result = queue.work
        sleep sleep_for
      end

      count = result.values.inject(0) { |a,v| a+v }

      break if $exit

      if count.zero?
        sleep sleep_for
      else
        say "#{count} jobs processed at %.4f j/s, %d failed ..." % [count / realtime, result[:error]]
      end

      break if $exit
    end

  ensure
    queue.clear_locks!
  end

  def say(text)
    puts text unless options[:quiet]
  end

private ######################################################################

  def quiet
    options[:quiet]
  end

end
