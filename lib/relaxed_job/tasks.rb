require 'relaxed_job/worker'

def relaxed_job_url
  ENV['RELAXED_JOB_COUCHDB_URL'] || 'http://localhost:5984/relaxed_job'
end

namespace :jobs do

  desc "Run job daemon"
  task :work do
    RelaxedJob::Worker.new(relaxed_job_url).start
  end

  task :test do
    queue = RelaxedJob::Queue.new(relaxed_job_url)
    queue.enqueue_with_method("", :to_s)
  end

end
