require 'active_resource'
class Order < ActiveResource::Base

  self.site = 'http://tocat.clients.opsway.com'
  self.collection_name = 'orders'
  self.element_name = 'order'


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


  def set_invoice(invoice)
    begin
      connection.post("#{Order.prefix}/order/#{self.id}/invoice", {invoice_id: invoice.id}.to_json)
    rescue => error
      # TODO add logger
      return false, error
    end
    return true, nil
  end

  def self.find_by_name(name)
    all_records = Order.find(:all, params: {limit:1000000000})
    unless all_records.count == 0
      all_records.each { |r| return Order.find(r.id) if r.name == name }
    end
    nil
  end
end
