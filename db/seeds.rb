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

segments.each do |segment|
  if !Segment.find_by(tm_segment_id: segment[:tm_segment_id])
    Segment.create(segment)
  end
end

genres.each do |genre|
  if !Genre.find_by(tm_genre_id: genre[:tm_genre_id])
    Genre.create(genre)
  end
end

sub_genres.each do |sub_genre|
  if !SubGenre.find_by(tm_sub_genre_id: sub_genre[:sub_genre_id])
    SubGenre.create(sub_genre)
  end
end

event_dates = JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/events?apikey=sqj3GomEiDTyMWkLzNhfrH0r62ZC82EA&startDateTime=2019-06-01T00:00:00Z&endDateTime=2019-06-30T23:59:00Z&city=London&countryCode=GB&page=0&size=200"))

venues = Set.new
event_dates_list = Set.new
events = Set.new

event_dates["_embedded"]["events"].each do |event_date|
  event_dates_list.add({
      tm_event_date_id: event_date["id"],
      event_date_name: event_date["name"],
      url: event_date["url"],
      sales_start_date: (!!event_date["sales"]["public"]["startDateTime"] ? event_date["sales"]["public"]["startDateTime"][0..9] : nil),
      sales_end_date: (!!event_date["sales"]["public"]["endDateTime"] ? event_date["sales"]["public"]["endDateTime"][0..9] : nil),
      start_date: event_date["dates"]["start"]["localDate"],
      start_time: event_date["dates"]["start"]["localTime"],
      event_id: event_date["_embedded"]["attractions"][0]["id"],
      venue_id: event_date["_embedded"]["venues"][0]["id"],
    })
  
  venue = event_date["_embedded"]["venues"][0]
    
  venues.add({
    tm_venue_id: venue["id"],
    venue_name: venue["name"],
    url: venue["url"],
    postcode: venue["postalCode"],
    city: venue["city"]["name"],
    country: venue["country"]["name"],
    address: (!!venue["address"] ? venue["address"]["line1"] : nil),
    longitude: venue["location"]["longitude"],
    latitude: venue["location"]["latitude"]
  })

  event = event_date["_embedded"]["attractions"][0]

  events.add({
      tm_event_id: event["id"],
      event_name: event["name"],
      url: event["url"],
      segment_id: Segment.find_by(tm_segment_id: event["classifications"][0]["segment"]["id"]).id,
      genre_id: Genre.find_by(tm_genre_id: event["classifications"][0]["genre"]["id"]).id,
      sub_genre_id: SubGenre.find_by(tm_sub_genre_id: event["classifications"][0]["subGenre"]["id"]).id
    })

end

venues.each do |venue|
  if !Venue.find_by(tm_venue_id: venue[:tm_venue_id])
    Venue.create(venue)
  end
end

events.each do |event|
  if !Event.find_by(tm_event_id: event[:tm_event_id])
    Event.create(event)
  end
end

event_dates_list.each do |event_date|
  event_date[:venue_id] = (!!Venue.find_by(tm_venue_id: event_date[:venue_id]) ? Venue.find_by(tm_venue_id: event_date[:venue_id]).id : event_date[:venue_id])
end

event_dates_list.each do |event_date|
  event_date[:event_id] = (!!Event.find_by(tm_event_id: event_date[:event_id]) ? Event.find_by(tm_event_id: event_date[:event_id]).id : event_date[:event_id])
end

event_dates_list.each do |event_date|
  if !EventDate.find_by(tm_event_date_id: event_date[:tm_event_date_id])
    EventDate.create(event_date)
  end
end

user_list = [
  ["username1", "password1", "first", "last", "email", "London", "UK"],
]

user_list.each do |username, password, first_name, last_name, email, city, country|
  User.create(username: username, password: password, first_name: first_name, last_name: last_name, email: email, city: city, country: country)
end

