#!/Users/zmoki/.rvm/rubies/ruby-1.9.3-p547/bin/ruby

require 'active_record'
require 'sqlite3'
ActiveRecord::Base.establish_connection(
    :adapter  => 'sqlite3',
    :database => 'example.db'
)

require 'pry'
require 'bigdecimal'
require 'active_record'
require 'sqlite3'
require_relative 'lib/zoho'
require_relative 'lib/order'
require_relative 'lib/team'
require_relative 'lib/task'
require_relative 'lib/invoice'
require_relative 'lib/user'
require_relative 'lib/ar'
require_relative 'lib/patches/active_resource_errors'



if __FILE__ == $PROGRAM_NAME
  site = 'http://localhost'
  Invoice.site = site
  Order.site = site
  Task.site = site
  Team.site = site
  User.site = site
  start_time = Time.now
  puts "press y to accept records count"
  status = false
  while !status do
    invoices = Zoho.get_invoices
    puts "Invoices - #{invoices.count}"
    input = gets
    status = true if input == "y\n"
  end

  invoices.each do |invoice|
    params = {}
    params[:paid] = invoice["Paid"]
    params[:external_id] = invoice["Number"]
    params[:client] = invoice["Client"]
    DB::Invoice.create!(params)
  end
  puts "Invoices saved"

  status = false
  while !status do
    suborders = Zoho.get_sub_orders
    puts "Suborders - #{suborders.count}"
    input = gets
    status = true if input == "y\n"
  end

  suborders.each do |record|
    params = {}
    params[:main_order] = record["MainOrder"]
    params[:sub_order] = record["SubOrder"]
    DB::SubOrder.create!(params)
  end
  puts "Suborders saved"

  status = false
  while !status do
    orders = Zoho.get_orders
    puts("Orders - #{orders.count}")
    input = gets
    status = true if input == "y\n"
  end

  orders.each do |record|
    params = {}
    params[:comment] = record["Comment"]
    params[:team] = record["Team"]
    params[:description] = record["Description"]
    params[:i_budget] = record["Invoiced_Budget"]
    params[:a_budget] = record["Allocatable_Budget"]
    params[:invoice] = record["Invoice"]
    params[:completed] = record["Completed"]
    params[:paid] = record["Paid"]
    params[:number] = record["Number"]
    DB::Order.create!(params)
  end
  puts "Orders saved"

  status = false
  while !status do
    tasks = Zoho.get_tasks
    puts("Tasks - #{tasks.count}")
    input = gets
    status = true if input == "y\n"
  end

  tasks.each do |record|
    params = {}
    params[:external_id] = record["Issue_ID"]
    params[:resolver] = record["Resolver"]
    params[:accepted] = record["Accepted"]
    DB::Task.create!(params)
  end
  puts "Tasks saved"

  status = false
  while !status do
    budgets = Zoho.get_task_orders
    puts("TaskOrders - #{budgets.count}")
    input = gets
    status = true if input == "y\n"
  end

  budgets.each do |record|
    params = {}
    params[:issue_id] = record["Issue"]
    params[:order_number] = record["OrderEntity"]
    params[:budget] = record["allocated_budget"]
    DB::IssueOrder.create!(params)
  end
  puts "TaskOrders saved"


  DB::Task.all.each do |issue|
    task = Task.create(issue.attributes)
    if issue.resolver.present?
      status, payload = task.set_resolver(User.find_by_name(issue.resolver).id)
      unless status
        puts "Exception while setting resolver for #{task.external_id}. Error: #{payload}"
      end
    end
  end
  puts "#{Task.find(:all, params:{limit:10000000}).count} tasks was created!"

  DB::Invoice.all.each do |invoice|
    params = invoice.attributes
    params[:paid] = false
    unless Invoice.create(params)
      puts "#{invoice.external_id} wont save!"
    end
  end
  puts "#{Invoice.find(:all, params:{limit:10000000}).count} invoices was created!"

  DB::Order.all.each do |order|
    team = Team.find_by_name(order.team)
    order_record = Order.find_by_name(order.comment)
    unless order_record.present?
      order_record = Order.new(invoiced_budget: order.i_budget.split('$ ')[1].gsub(',',''),
                            allocatable_budget: order.a_budget.split('$ ')[1].gsub(',',''),
                            name: order.comment,
                            description: order.description,
                            completed: order.completed,
                            team:{id:team.id})
      unless order_record.save
        puts " Order #{order_record.name} wont save! Error #{order_record.errors['message']}"
        next
      else
        unless order.invoice.empty?
          status, payload = order_record.set_invoice(Invoice.find_by_external_id(order.invoice))
          unless status
            puts "Exception while setting invoice for #{order_record.name}. Error: #{payload}"
          end
        end
      end
    end
  end
  puts "#{Order.find(:all, params:{limit:10000000}).count} orders was created!"


  DB::Order.all.each do |order|
    DB::SubOrder.all.each do |sub_order|
      if order.number == sub_order.main_order
        sub_order_comment = DB::Order.where(number: sub_order.sub_order).first.comment
        main_order_record = Order.find_by_name(order.comment)
        sub_order_record = Order.find_by_name(sub_order_comment)
        unless sub_order_record.update_attribute(:parent_id, main_order_record.id)
          puts "Exception while setting #{sub_order_record.name} as suborder for #{main_order_record.name}"
        end
      end
    end
  end
  puts "SubOrders was setted!"

  Task.find(:all, params:{limit:10000000}).each do |task|
    if DB::IssueOrder.where(issue_id:task.external_id).present?
      budgets = []
      DB::IssueOrder.where(issue_id:task.external_id).each do |record|
        unless record.budget.split('$ ')[1].gsub(',','').to_i == 0
          order = DB::Order.where(number: record.order_number).first
          budgets << {order_id: order.id, budget:record.budget.split('$ ')[1].gsub(',','')}
        end
      end
      status, payload = task.set_budgets(budgets)
      unless status
        puts "#{payload.response.body}, #{task.external_id}, #{budgets}"
      end
    end
  end
  puts "Budgets was setted!"


  Invoice.find(:all, params:{limit:10000000}).each do |invoice|
    zoho_record = DB::Invoice.where(external_id:invoice.external_id).first
    if zoho_record.paid
      status, payload = invoice.set_paid
      unless status
        binding.pry
      end
    end
  end
  puts "Invoices was paid!"

  puts "Check issues..."

  Task.find(:all, params:{limit:10000000}).each do |task|
    zoho = DB::Task.where(external_id:task.external_id).first
    task = Task.find(task.id)
    unless zoho.resolver.empty?
      puts "Task #{task.id} has wrong resolver" if zoho.resolver != task.resolver.name
    end
  end

  puts "Check invoices..."

  Invoice.find(:all, params:{limit:10000000}).each do |invoice|
    zoho = DB::Invoice.where(external_id:invoice.external_id).first
    invoice = Invoice.find(invoice.id)
    puts "Invoice #{invoice.id} has wrong paid status" if zoho.paid != invoice.paid
  end

  puts "Check orders..."

  Order.find(:all, params:{limit:10000000}).each do |order|
    zoho = DB::Order.where(comment:order.name).first
    order = Order.find(order.id)
    puts "Order #{order.id} has wrong team" if zoho.team != order.team.name
    puts "Order #{order.id} has wrong paid" if zoho.paid != order.paid
    puts "Order #{order.id} has wrong invoiced budget" if zoho.i_budget.split('$ ')[1].gsub(',','').to_f != order.invoiced_budget
    puts "Order #{order.id} has wrong allocatable budget" if zoho.a_budget.split('$ ')[1].gsub(',','').to_f != order.allocatable_budget
  end


  puts "Completed in #{Time.now - start_time}."
  puts "Exiting!"
end
