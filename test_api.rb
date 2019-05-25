require 'pry'
require 'rest-client'
require 'JSON'


binding.pry
""
#Take event data and split it up into events, venues,
#attractions, segment, genre, sub-genre tables

#api call for suggest in GB
#events = JSON.parst(RestClient.get("https://app.ticketmaster.com/discovery/v2/suggest?apikey=sqj3GomEiDTyMWkLzNhfrH0r62ZC82EA&countryCode=GB"))

#events = JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/events.json?apikey=sqj3GomEiDTyMWkLzNhfrH0r62ZC82EA"))

=begin
Selects all classification date from ticketmaster
splits it into segments, genres, and sub_genres
imports data into database

**This does not need to be re-run unless data 
needs to be refreshed in database as does not 
check items already exist **
=end

classifications = JSON.parse(RestClient.get("https://app.ticketmaster.com//discovery/v2/classifications.json?apikey=sqj3GomEiDTyMWkLzNhfrH0r62ZC82EA"))

segments = Set.new
genres = Set.new
sub_genres = Set.new

classifications["_embedded"]["classifications"][11..-1].each do |c|
  segments.add({tm_segment_id: c["segment"]["id"], segment_name: c["segment"]["name"]})
  
  c["segment"]["_embedded"]["genres"].each do |g|
    genres.add({tm_genre_id: g["id"], genre_name: g["name"]})
    
    g["_embedded"]["subgenres"].each do |s|
      sub_genres.add({tm_sub_genre_id: s["id"], sub_genre_name: s["name"]})
    end
  end
end

segments.each{|segment| Segment.create(segment)}
genres.each{|genre| Genre.create(genre)}
sub_genres.each{|sub_genre| SubGenre.create(sub_genre)}

#api call for events in London in June (100 events per page)
events = JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/events?apikey=sqj3GomEiDTyMWkLzNhfrH0r62ZC82EA&startDateTime=2019-06-01T00:00:00Z&endDateTime=2019-06-30T23:59:00Z&city=London&countryCode=GB&page=0&size=100"))

#Create sets (prevent duplicates) of venues and
#create array of hash events (with tm_venue_id)
#Create venues in database.
#Update events with db venue id and then create events in db

venues = Set.new
events_list = []

events["_embedded"]["events"].each do |event|
  events_list << {
      tm_event_id: event["id"],
      event_name: event["name"],
      url: event["url"],
      sales_start_date: event["sales"]["public"]["startDateTime"][0..9],
      sales_end_date: event["sales"]["public"]["endDateTime"][0..9],
      start_date: event["dates"]["start"]["localDate"],
      start_time: event["dates"]["start"]["localTime"],
      venue_id: event["_embedded"]["venues"][0]["id"],
      segment_id: Segment.find_by(tm_segment_id: event["classifications"][0]["segment"]["id"]).id,
      genre_id: Genre.find_by(tm_genre_id: event["classifications"][0]["genre"]["id"]).id,
      sub_genre_id: SubGenre.find_by(tm_sub_genre_id: event["classifications"][0]["subGenre"]["id"]).id
    }

  venue = event["_embedded"]["venues"][0]
    
  venues.add({
    tm_venue_id: venue["id"],
    venue_name: venue["name"],
    url: venue["url"],
    postcode: venue["postalCode"],
    city: venue["city"]["name"],
    country: venue["country"]["name"],
    address: venue["address"]["line1"],
    longitude: venue["location"]["longitude"],
    latitude: venue["location"]["latitude"]
  })

end

venues.each{|venue| Venue.create(venue)}

events_list.each do |event|
  event[:venue_id] = Venue.find_by(tm_venue_id: event[:venue_id]).id
end

events_list.each{|event| Event.create(event)}