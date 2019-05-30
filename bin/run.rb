require_relative '../config/environment'


# binding.pry

APIKEY = "sqj3GomEiDTyMWkLzNhfrH0r62ZC82EA"
EVENTSURL = "https://app.ticketmaster.com/discovery/v2/events?"
CLASSURL = "https://app.ticketmaster.com/discovery/v2/events?"


session = UserInterface.new
session.first_page

binding.pry
puts "HELLO WORLD"
