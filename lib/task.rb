class Task < ActiveResource::Base
  self.site = 'http://localhost:3000'
  self.collection_name = 'task'

  class << self
    def element_path(id, prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}/#{id}#{query_string(query_options)}"
    end

    def collection_path(prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
    end
  end

  def self.find_by_external_id(id)
    id = id.to_s
    all_records = Task.all
    all_records.each { |r| return Task.find(r.id) if r.external_id == id }
    nil
  end

end
