class Event < ActiveRecord::Base
    has_many :user_events
    has_many :users, through: :user_events
    has_many :reviews
    has_many :event_dates
    belongs_to :segment
    belongs_to :genre
    belongs_to :sub_genre
    

    def average_rating
        (self.reviews.inject(0){|sum, review| sum + review.rating}/self.reviews.length.to_f).round(2)
    end

    def display_reviews
        if reviews.length == 0
            puts "Therea are no reviews for this event"
        else
            puts "Overall rating: #{average_rating}"
            puts "--------------------------"
        reviews.each.with_index(1) do |review, i|
            puts "Review #{i}: #{review.event.event_name}"
            puts "Rating: #{review.rating}"
            puts "Review: #{review.review}"
            puts "Reviewed by: #{review.user.first_name}"
            puts "--------------------------"
        end
    end
    end
end