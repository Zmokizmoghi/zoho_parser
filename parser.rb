#!/Users/zmoki/.rvm/rubies/ruby-1.9.3-p547/bin/ruby
require 'pry'
require 'bigdecimal'
require_relative 'lib/zoho'
require_relative 'lib/zoho_order'


tocat_host = 'http://localhost:3000'



if __FILE__ == $PROGRAM_NAME
  puts ENV['AUTH_KEY']
  orders = ZohoOrder.get_all
  binding.pry
end
