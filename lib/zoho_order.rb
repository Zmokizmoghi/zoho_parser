require 'active_resource'
class ZohoOrder < ActiveResource::Base

  self.site = 'http://localhost:3000'
  self.collection_name = 'order'

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

  # attr_accessor :paid,
  #               :description,
  #               :sub_order,
  #               :number,
  #               :completed,
  #               :allocatable_budget,
  #               :comment,
  #               :zoho_id,
  #               :invoice,
  #               :team,
  #               :invoiced_budget,
  #               :budget
  #
  # def initialize(options)
  #   @paid = options['Paid']
  #   @description = options['Description']
  #   @sub_order = options['SubOrder']
  #   @number = options['Number']
  #   @completed = options['Completed']
  #   @allocatable_budget = BigDecimal( options['Allocatable_Budget'].split('$ ')[1])
  #   @comment = options['Comment']
  #   @zoho_id = options['ID']
  #   @invoice = options[:'Invoice']
  #   @team = options['Team']
  #   @invoiced_budget = BigDecimal(options['Invoiced_Budget'].split('$ ')[1])
  #   @budget = BigDecimal(options['Budget'].split('$ ')[1])
  # end
end
