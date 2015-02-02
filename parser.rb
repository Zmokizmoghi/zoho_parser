#!/Users/zmoki/.rvm/rubies/ruby-1.9.3-p547/bin/ruby
require 'pry'
require 'bigdecimal'
require_relative 'lib/zoho'
require_relative 'lib/zoho_order'
require_relative 'lib/team'
require_relative 'lib/patches/active_resource_errors'



tocat_host = 'http://localhost:3000'



if __FILE__ == $PROGRAM_NAME
  orders = Zoho.get_orders
  binding.pry
end
