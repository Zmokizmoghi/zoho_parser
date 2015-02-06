#!/Users/zmoki/.rvm/rubies/ruby-1.9.3-p547/bin/ruby
require 'pry'
require 'bigdecimal'
require_relative 'lib/zoho'
require_relative 'lib/zoho_order'
require_relative 'lib/team'
require_relative 'lib/task'
require_relative 'lib/user'
require_relative 'lib/patches/active_resource_errors'



tocat_host = 'http://localhost:3000'



if __FILE__ == $PROGRAM_NAME
  puts ENV['AUTH_KEY']
  orders = Zoho.get_orders
  orders.each do |order|
    team = Team.find_by_name(order['Team'])
    order = ZohoOrder.find_by_name(order['Comment'])
    unless order.present?
      order = ZohoOrder.new(invoiced_budget: order['Invoiced_Budget'].split('$ ')[1].gsub(',',''),
                            allocatable_budget: order['Allocatable_Budget'].split('$ ')[1].gsub(',',''),
                            name: order['Comment'],
                            description: order['Description'],
                            team:{id:team.id})
      unless a.save
        puts " Order #{a.name} wont save! Error #{a.errors['message']}"
        next
      end
    end
    issues = Zoho.get_issues_for_order(order['ID'])
    query = []
    task = ''
    issues.each do |issue|
      task = Task.find_by_external_id issue['Issue']
      unless task
        task = Task.create external_id: issue['Issue']
      end
      query = []
      query << {'order_id' => a.id, 'budget' => issue['allocated_budget'].split('$ ')[1]}
      Task.find(task.id).post(:budget, {}, {'budget' => query}.to_json)
      t = Zoho.get_task(issue['Issue'])
      if t['Resolver'].present?
        begin
          task.post(:resolver, {}, {'user_id' => User.find_by_name(t['Resolver']).id}.to_json)
        rescue
          binding.pry
        end
        puts "User #{t['Resolver']} set as resolver for #{task.external_id} task."
      end
    end
  end
end
