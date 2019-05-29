class Event < ActiveRecord::Base
    has_many :user_events
    has_many :users, through: :user_events
    has_many :reviews
    has_many :event_dates
    belongs_to :segment
    belongs_to :genre
    belongs_to :sub_genre

    def self.get_json_from_search_string(search_string, page_no)
        [JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/events?apikey=sqj3GomEiDTyMWkLzNhfrH0r62ZC82EA#{search_string}&page=#{page_no}&size=10")), search_string, page_no]
    end

    def self.new_event_search(events_json, search_string, page_no)
        if events_json["page"]["totalElements"] == 0
            events = [[]]
            next_url = nil
        else
            events = events_json["_embedded"]["events"]
            next_url = events_json["_links"]["next"]

            events = [events.map do |event_date|
                [{
                tm_event_date_id: event_date["id"],
                event_date_name: event_date["name"],
                url: event_date["url"],
                start_date: event_date["dates"]["start"]["localDate"],
                start_time: event_date["dates"]["start"]["localTime"]
                },
                {
                tm_venue_id: event_date["_embedded"]["venues"][0]["id"],
                venue_name: event_date["_embedded"]["venues"][0]["name"],
                url: event_date["_embedded"]["venues"][0]["url"],
                postcode: event_date["_embedded"]["venues"][0]["postalCode"],
                city: event_date["_embedded"]["venues"][0]["city"]["name"],
                country: event_date["_embedded"]["venues"][0]["country"]["name"]
                },
                {
                tm_event_id: event_date["_embedded"]["attractions"][0]["id"],
                event_name: event_date["_embedded"]["attractions"][0]["name"],
                url: event_date["_embedded"]["attractions"][0]["url"],
                segment_id: Segment.find_by(tm_segment_id: event_date["_embedded"]["attractions"][0]["classifications"][0]["segment"]["id"]).id,
                genre_id: Genre.find_by(tm_genre_id: event_date["_embedded"]["attractions"][0]["classifications"][0]["genre"]["id"]).id,
                sub_genre_id: SubGenre.find_by(tm_sub_genre_id: event_date["_embedded"]["attractions"][0]["classifications"][0]["subGenre"]["id"]).id
                }]
            end]
        end
        events << search_string << page_no << next_url
    end

    def display_events(events)
        if events.length == 0
            puts "Your search returned no events"
        else
            events.each.with_index(1) do |event, i|
                puts "Event #{i}: #{events[:event_name]}"
                puts "Event name: #{events[:event_date_name]}"
                puts "When: #{events[:start_date]} at #{events[:start_time]}"
                puts "Where: #{events[:venue_name]}, #{events[:city]}, #{events[:postcode]}"
                puts "--------------------------" if i < user_events.length
            end
        end
    end

    
end