# config/initializers/high_voltage.rb
## enables use of address without pages in it
## http://goodworksonearth.net/about vs 
## http://goodworksonearth.net/pages/about

HighVoltage.configure do |config|
  config.route_drawer = HighVoltage::RouteDrawers::Root
end