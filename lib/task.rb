class Task < ActiveResource::Base
  self.site = 'http://localhost'
  self.collection_name = 'tasks'
  self.element_name = 'task'


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

  def self.find_by_external_id(id)
    id = id.to_s
    all_records = Task.find(:all, params: {limit:1000000000})
    all_records.each { |r| return Task.find(r.id) if r.external_id == id }
    nil
  end

  def set_resolver(resolver)
    begin
      connection.post("#{Task.prefix}/task/#{self.id}/resolver", {user_id: resolver}.to_json)
    rescue => error
      # TODO add logger
      return false, error
    end
    return true, nil
  end

  def set_budgets(budgets)
    begin
      connection.post("#{Task.prefix}/task/#{self.id}/budget", {budget: budgets}.to_json)
    rescue => error
      # TODO add logger
      return false, error
    end
    return true, nil
  end

end
