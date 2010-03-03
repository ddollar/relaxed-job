module CouchRest::Mixins::Finders

  def find_or_initialize(id)
    self.get(id)
  rescue RestClient::ResourceNotFound
    { "_id" => id }
  end

  def all(view, options={})
    self.view(view, options)["rows"].inject({}) do |hash, row|
      hash.update(row["key"] => row["value"])
    end
  end

  def first(view, options={})
    self.view(view, options)["rows"].first
  rescue RestClient::ResourceNotFound
    nil
  end

  def one(view, key)
    first(view, :key => key)["value"]
  end

end
