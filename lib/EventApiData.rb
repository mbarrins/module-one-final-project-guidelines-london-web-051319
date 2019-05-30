class EventApiData < ApiData
  attr_accessor :search_string, :page_no, :page_size, :next_url

  def initialize(url:, search_string: nil, api_key: nil, page_no: 0, page_size: 10)
    super
    @search_string = search_string
    @page_no = page_no
    @page_size = page_size
  end

  def self.new_with_data(url:, search_string:, api_key:, page_no: 0, page_size: 10)
    event = EventApiData.new(url: url, search_string: search_string, api_key: api_key, page_no: page_no, page_size: page_size)
    event.get_data
    event
  end

  def get_data
    @data = JSON.parse(RestClient.get(self.url + "apikey=#{self.api_key}" + self.search_string + "&page=#{self.page_no}&size=#{self.page_size}"))
    @next_url = (self.data["page"]["totalElements"] == 0 ? next_url = nil : self.data["_links"]["next"])
  end

  def search_results
    if !self.data || self.data["page"]["totalElements"] == 0
        events = []
        # next_url = nil
    else
        events = self.data["_embedded"]["events"]
        # next_url = events_json["_links"]["next"]

        events = events.map do |event_date|
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
            tm_event_id: (!!event_date["_embedded"]["attractions"] ? event_date["_embedded"]["attractions"][0]["id"] : event_date["id"]),
            event_name: (!!event_date["_embedded"]["attractions"] ? event_date["_embedded"]["attractions"][0]["name"] : event_date["name"]),
            url: (!!event_date["_embedded"]["attractions"] ? event_date["_embedded"]["attractions"][0]["url"] : event_date["url"]),
            segment_id: Segment.find_by(tm_segment_id: event_date["classifications"][0]["segment"]["id"]).id,
            genre_id: Genre.find_by(tm_genre_id: event_date["classifications"][0]["genre"]["id"]).id,
            sub_genre_id: SubGenre.find_by(tm_sub_genre_id: event_date["classifications"][0]["subGenre"]["id"]).id
            }]
        end
    end
    events #<< search_string << page_no << next_url
end

end