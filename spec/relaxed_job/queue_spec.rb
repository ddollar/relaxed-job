require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "RelaxedJob::Queue" do

  before(:each) do
    @queue    = test_delayed_job_queue
    @enqueued = TestFileWriter.new
  end

  after(:all) do
    couchdb_cleanup
  end

  describe "using enqueue to queue a class" do
    before(:each) do
      @queue.enqueue @enqueued
      @results = @queue.work
    end

    it "has the right data in the file" do
      File.read(@enqueued.filename).should == 'perform'
    end

    it "returns the count of jobs" do
      @results.should == { :complete => 1, :error => 0 }
    end
  end

  describe "using enqueue_with_method to call a different method" do
    before(:each) do
      @queue.enqueue_with_method @enqueued, :perform_two
      @queue.work
    end

    it "has the right data in the file" do
      File.read(@enqueued.filename).should == 'perform_two'
    end
  end

  describe "using enqueue_with_method to call a method with arguments" do
    before(:each) do
      @queue.enqueue_with_method @enqueued, :perform_args, 'one', 'two'
      @queue.work
    end

    it "has the right data in the file" do
      File.read(@enqueued.filename).should == '["one", "two"]'
    end
  end

  describe "with an erroring method" do
    before(:each) do
      @queue.enqueue_with_method @enqueued, :perform_with_error, 'ErrorText'
      @results = @queue.work
    end

    it "stores the errored job with its exception" do
      job = @queue.errored_jobs.last
      exception = Marshal.load(job['exception'])
      exception.message.should == 'ErrorText'
    end

    it "returns the count of jobs" do
      @results.should == { :complete => 0, :error => 1 }
    end
  end

  describe "with locked jobs" do
    before(:each) do
      @queue.enqueue_with_method @enqueued, :perform_with_error, 'ErrorText'
      @queue.lock(1)
    end
    
    it "should be able to unlock jobs" do
      @queue.locked_jobs.length.should == 1
      @queue.clear_locks!
      @queue.locked_jobs.length.should == 0
    end
  end
  
end
