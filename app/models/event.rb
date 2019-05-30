class Event < ActiveRecord::Base
    has_many :user_events
    has_many :users, through: :user_events
    has_many :reviews
    has_many :event_dates
    belongs_to :segment
    belongs_to :genre
    belongs_to :sub_genre

    # def display_events(events_data)
    #     if events_data.length == 0
    #         puts "Your search returned no events"
    #     else
    #         events_data.each.with_index(1) do |event, i|
    #             puts "Event #{i}: #{events_data[:event_name]}"
    #             puts "Event name: #{events_data[:event_date_name]}"
    #             puts "When: #{events_data[:start_date]} at #{events_data[:start_time]}"
    #             puts "Where: #{events_data[:venue_name]}, #{events_data[:city]}, #{events_data[:postcode]}"
    #             puts "--------------------------"
    #         end
    #     end
    # end

    
end