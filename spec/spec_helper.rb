require "rubygems"
require "couchrest"

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "relaxed-job"
require "spec"
require "spec/autorun"

TEST_RELAXED_JOB_URL = "http://localhost:5984/relaxed_job_test"

class TestFileWriter
  attr_reader :filename

  def initialize
    @filename = "/tmp/relaxed_job_test/#{rand(1000000)}.file"
  end

  def perform
    write_to_file("perform")
  end

  def perform_two
    write_to_file("perform_two")
  end

  def perform_args(*args)
    write_to_file(args.inspect)
  end

  def perform_with_error(message)
    raise message
  end

  def write_to_file(data)
    File.open(filename, "w") do |file|
      file.print data
    end
  end
end

def test_delayed_job_queue
  RelaxedJob::Queue.new(TEST_RELAXED_JOB_URL)
end

def couchdb_cleanup
  CouchRest.database(TEST_RELAXED_JOB_URL).delete!
end

Spec::Runner.configure do |config|
  config.before(:all) do
    FileUtils.mkdir_p "/tmp/relaxed_job_test"
  end

  config.after(:all) do
    FileUtils.rm_rf "/tmp/relaxed_job_test"
  end
end
