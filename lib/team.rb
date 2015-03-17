require 'active_resource'
class Team < ActiveResource::Base

  self.collection_name = 'teams'
  self.element_name = 'team'


  class << self
    def element_path(id, prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{element_name}/#{id}#{query_string(query_options)}"
    end

    def collection_path(prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
    end
  end

  def self.find_by_name(name)
    all_records = Team.find(:all, params: {limit:1000000000})
    all_records.each { |r| return Team.find(r.id) if r.name == name }
    nil
  end
end
