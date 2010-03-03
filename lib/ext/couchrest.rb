require "ext/couchrest/mixins/design_files"
require "ext/couchrest/mixins/finders"

class CouchRest::Database
  include CouchRest::Mixins::DesignFiles
  include CouchRest::Mixins::Finders
end
