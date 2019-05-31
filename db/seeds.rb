class_api = ClassificationApiData.new(url: CLASSURL, api_key: APIKEY)
class_api.populate_tables

user_list = [
  ["username1", "password1", "Jerry", "Berry", "email1@email.com", "London", "GB"],
  ["username2", "password1", "Barold", "Thampson", "email2@email.com", "London", "GB"]
  ["username3", "password1", "Phteven", "Fork", "email3@email.com", "Birmingham", "GB"]
  ["username4", "password1", "Terry", "Swelve", "email4@email.com", "Torquay", "GB"]
  ["username5", "password1", "Brenda", "Shortgun", "email5@email.com", "London", "GB"]
  ["username6", "password1", "Harnold", "Alice", "email6@email.com", "Edinburgh", "GB"]
  ["username7", "password1", "Jenkin", "Yes", "email7@email.com", "Truro", "GB"]
  ["username8", "password1", "Perkin", "No", "email8@email.com", "Bristol", "GB"]
  ["username9", "password1", "Doris", "Night", "email9@email.com", "Nottingham", "GB"]
  ["username10", "password1", "Dorothea", "Apple", "email10@email.com", "Oxford", "GB"]
  ["username11", "password1", "Freddo", "Goffinger", "email11@email.com", "Cambridge", "GB"]
  ["username12", "password1", "Gerild", "Berild", "email12@email.com", "Toronto", "Canada"]
  ["username13", "password1", "Horatia", "No", "email13@email.com", "New York", "USA"]
  ["jaffa", "cake", "Jaffa", "Cake", "email14@email.com", "Auckland", "New Zealand"]
]

user_list.each do |username, password, first_name, last_name, email, city, country|
  User.create(username: username, password: password, first_name: first_name, last_name: last_name, email: email, city: city, country: country)
end

user2 = User.create(username: "a", password: "b", first_name: "a", last_name: "b", email: "c")


# Below is to populate event_dates, events, and venues tables with some data.

# event_dates = JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/events?apikey=sqj3GomEiDTyMWkLzNhfrH0r62ZC82EA&startDateTime=2019-06-01T00:00:00Z&endDateTime=2019-06-30T23:59:00Z&city=London&countryCode=GB&page=0&size=200"))

# venues = Set.new
# event_dates_list = Set.new
# events = Set.new

# event_dates["_embedded"]["events"].each do |event_date|
#   event_dates_list.add({
#       tm_event_date_id: event_date["id"],
#       event_date_name: event_date["name"],
#       url: event_date["url"],
#       start_date: event_date["dates"]["start"]["localDate"],
#       start_time: event_date["dates"]["start"]["localTime"],
#       event_id: event_date["_embedded"]["attractions"][0]["id"],
#       venue_id: event_date["_embedded"]["venues"][0]["id"],
#     })
  
#   venue = event_date["_embedded"]["venues"][0]
    
#   venues.add({
#     tm_venue_id: venue["id"],
#     venue_name: venue["name"],
#     url: venue["url"],
#     postcode: venue["postalCode"],
#     city: venue["city"]["name"],
#     country: venue["country"]["name"]
#   })

#   event = event_date["_embedded"]["attractions"][0]

#   events.add({
#       tm_event_id: event["id"],
#       event_name: event["name"],
#       url: event["url"],
#       segment_id: Segment.find_by(tm_segment_id: event["classifications"][0]["segment"]["id"]).id,
#       genre_id: Genre.find_by(tm_genre_id: event["classifications"][0]["genre"]["id"]).id,
#       sub_genre_id: SubGenre.find_by(tm_sub_genre_id: event["classifications"][0]["subGenre"]["id"]).id
#     })

# end

# venues.each do |venue|
#   if !Venue.find_by(tm_venue_id: venue[:tm_venue_id])
#     Venue.create(venue)
#   end
# end

# events.each do |event|
#   if !Event.find_by(tm_event_id: event[:tm_event_id])
#     Event.create(event)
#   end
# end

# event_dates_list.each do |event_date|
#   event_date[:venue_id] = (!!Venue.find_by(tm_venue_id: event_date[:venue_id]) ? Venue.find_by(tm_venue_id: event_date[:venue_id]).id : event_date[:venue_id])
# end

# event_dates_list.each do |event_date|
#   event_date[:event_id] = (!!Event.find_by(tm_event_id: event_date[:event_id]) ? Event.find_by(tm_event_id: event_date[:event_id]).id : event_date[:event_id])
# end

# event_dates_list.each do |event_date|
#   if !EventDate.find_by(tm_event_date_id: event_date[:tm_event_date_id])
#     EventDate.create(event_date)
#   end
# end