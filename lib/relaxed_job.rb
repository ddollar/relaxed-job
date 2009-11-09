module RelaxedJob

  def self.couchdb(url)
    database = CouchRest.database!(url)
    database.update_designs(File.join(File.dirname(__FILE__), 'relaxed_job', 'designs'))
    database
  end

end

require 'relaxed_job/queue'
require 'relaxed_job/worker'
