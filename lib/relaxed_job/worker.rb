require "benchmark"
require "couchrest"
require "relaxed_job"

class RelaxedJob::Worker

  DEFAULT_SLEEP = 5

  attr_reader :queue
  attr_reader :options

  def initialize(couchdb_url, options={})
    @queue   = RelaxedJob::Queue.new(couchdb_url)
    @options = options
  end

  def start(options={})
    say "*** Starting job worker #{queue.lock_name}"

    trap("TERM") { unlock_and_exit! }
    trap("INT")  { unlock_and_exit! }

    queue.work self

  rescue Exception => ex
    return if ex.is_a? SystemExit
    say "Caught Exception: #{ex}"
    say ex.backtrace
    unlock_and_exit!
  end

## jobs ######################################################################

  def jobs
    @jobs ||= {}
  end

  def job(name, &blk)
    jobs[name.to_sym] = blk
  end

  def run(name, args={})
    name = name.to_sym
    raise "No such job: #{name}" unless job = jobs[name]
    job.call(args)
  end

private ######################################################################

  def say(text)
    puts text unless options[:quiet]
  end

  def unlock_and_exit!
    puts "Exiting..."
    queue.clear_locks!
    exit
  end

end
