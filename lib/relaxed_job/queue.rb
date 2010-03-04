require "couchrest"
require "relaxed_job"

class RelaxedJob::Queue

  attr_reader :couchdb_url
  attr_reader :options

  def initialize(couchdb_url)
    @couchdb_url = couchdb_url
    @options     = options
  end

  def job(id)
    couchdb.get(id)
  end

  def run(job, args={})
    couchdb.save_doc({
      "class"     => "job",
      "state"     => "pending",
      "name"      => job,
      "arguments" => args,
      "queued_at" => Time.now.utc
    })
  end

  def lock_name
    "host:#{Socket.gethostname} pid:#{$$}"
  rescue
    "pid:#{$$}"
  end

  def clear_locks!
    locked_jobs.each do |job|
      job["state"] = "pending"
      job.delete("locked_by")
      couchdb.save_doc(job)
    end
  end

  def work(worker)
    fetch_and_lock do |job|
      begin
        worker.run job["name"], job["arguments"]

        job["state"]        = "complete"
        job["completed_at"] = Time.now.utc
        couchdb.save_doc(job)
      rescue StandardError => ex
        job["state"]      = "error"
        job["errored_at"] = Time.now.utc
        job["error"]      = { "message" => ex.message, "backtrace" => ex.backtrace }
        couchdb.save_doc(job)
      end
    end
  end

## job types #################################################################

  def fetch_and_lock(&block)
    loop do
      changes = couchdb.get("_changes",
        :feed   => "longpoll",
        :filter => "jobs/pending",
        :since  => 1
      )

      lock_job changes["results"].first["id"], &block
    end
  end

  def lock_job(id)
    begin
      job = job(id)
      job["state"] = "running"
      job["locked_by"] = lock_name
      job.save
    rescue RestClient::Conflict
      return
    end

    yield job

    job.delete("locked_by")
    job.save
  end

  def completed_jobs
    jobs_by_type(:completed)
  end

  def errored_jobs
    jobs_by_type(:errored)
  end

  def locked_jobs
    jobs_by_type(:locked, :key => lock_name)
  end

private ######################################################################

  def couchdb
    @couchdb ||= RelaxedJob.couchdb(couchdb_url)
  end

  def jobs_by_type(type, options={})
    couchdb.view("jobs/#{type}", options)["rows"].map { |row| row["value"] }
  end

end
