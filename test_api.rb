require 'pry'
require 'rest-client'
require 'JSON'

events = JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/events.json?apikey=sqj3GomEiDTyMWkLzNhfrH0r62ZC82EA"))
#classifications = JSON.parse(RestClient.get("https://app.ticketmaster.com//discovery/v2/classifications.json?apikey=sqj3GomEiDTyMWkLzNhfrH0r62ZC82EA"))
#venues = JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/venues.json?apikey=sqj3GomEiDTyMWkLzNhfrH0r62ZC82EA"))

binding.pry
""
#Take event data and split it up into events, venues,
#attractions, segment, genre, sub-genre tables


