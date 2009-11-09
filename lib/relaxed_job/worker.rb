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

  def start
    say "*** Starting job worker #{queue.worker_name}"

    trap('TERM') { say 'Exiting...'; $exit = true }
    trap('INT')  { say 'Exiting...'; $exit = true }

    loop do
      result = nil

      realtime = Benchmark.realtime do
        result = queue.work
        sleep 1
      end

      count = result.values.inject(0) { |a,v| a+v }

      break if $exit

      if count.zero?
        sleep(SLEEP)
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
