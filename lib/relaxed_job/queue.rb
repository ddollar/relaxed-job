require 'couchrest'

class RelaxedJob::Queue

  attr_reader :couchdb_url
  attr_reader :options

  def initialize(couchdb_url)
    @couchdb_url = couchdb_url
    @options = options
  end

  def job(id)
    couchdb.get(id)
  end

  def enqueue(object, *args)
    enqueue_with_method object, :perform, *args
  end

  def enqueue_with_method(object, method, *args)
    couchdb.save_doc({
      'class'     => 'job',
      'state'     => 'pending',
      'method'    => method.to_s,
      'arguments' => args.to_a,
      'object'    => Marshal.dump(object),
      'queued_at' => Time.now.utc
    })
  end

  def lock(count)
    pending_jobs(count).each do |job|
      job['state']     = 'locked'
      job['locked_by'] = worker_name
      couchdb.save_doc(job)
    end
  end

  def clear_locks!
    locked_jobs.each do |job|
      job['state'] = 'pending'
      job.delete('locked_by')
      couchdb.save_doc(job)
    end
  end

  def work(worker_name=worker_name)
    lock 3

    counts = { :complete => 0, :error => 0 }

    locked_jobs.each do |job|
      begin
        object = Marshal.load(job['object'])
        retval = object.send(job['method'], *(job['arguments']))

        counts[:complete] += 1

        job['retval']       = retval
        job['state']        = 'complete'
        job['completed_at'] = Time.now.utc
        couchdb.save_doc(job)
      rescue StandardError => ex
        counts[:error] += 1

        job['state']      = 'error'
        job['exception']  = Marshal.dump(ex)
        job['errored_at'] = Time.now.utc
        couchdb.save_doc(job)
      end
    end

    counts
  end

  def worker_name
    "host:#{Socket.gethostname} pid:#{$$}"
  rescue
    "pid:#{$$}"
  end

## job types #################################################################

  def completed_jobs
    jobs_by_type(:completed)
  end

  def errored_jobs
    jobs_by_type(:errored)
  end

  def locked_jobs
    jobs_by_type(:locked, :key => worker_name)
  end

  def pending_jobs(count)
    jobs_by_type(:pending, :limit => count)
  end

private ######################################################################

  def couchdb
    @couchdb ||= RelaxedJob.couchdb(couchdb_url)
  end

  def jobs_by_type(type, options={})
    couchdb.view("jobs/#{type}", options)['rows'].map { |row| row['value'] }
  end

end
