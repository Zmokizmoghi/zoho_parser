require 'active_resource'
class Invoice < ActiveResource::Base
  self.collection_name = 'invoices'
  self.element_name = 'invoice'

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

  def self.find_by_external_id(external_id)
    all_records = Invoice.find(:all, params: {limit:1000000000})
    all_records.each { |r| return Invoice.find(r.id) if r.external_id == external_id }
    nil
  end

  def set_paid
    begin
      connection.post("#{Invoice.prefix}/invoice/#{self.id}/paid")
    rescue => error
      # TODO add logger
      return false, error
    end
    return true, nil
  end
end
