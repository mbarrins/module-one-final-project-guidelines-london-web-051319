class User < ActiveRecord::Base
    has_many :user_events
    has_many :event_dates, through: :user_events
    has_many :events, through: :event_dates
    has_many :reviews

    def future_user_events
        self.user_events.joins(:event_date).where("event_dates.start_date >= #{Date.today}")
    end

    def display_future_user_events
        display_user_event_details(self.future_user_events)
    end

    def display_all_user_events
        display_user_event_details(self.user_events)
    end

    def display_all_user_reviews
        display_user_review_details(self.reviews)
    end

    def user_reviewed_events
        self.reviews.map{|review| review.event}.uniq
    end

    def select_user_reviews_to_edit
        events = self.user_reviewed_events.sort
        [events.map{|event| event.id}, events.map.with_index(1){|event, i| "#{i}: #{event.event_name}"}]
    end

    def user_not_reviewed_events
        self.events.uniq - self.user_reviewed_events
    end

    def select_user_events_to_review
        events = self.user_not_reviewed_events.sort
        [events.map{|event| event.id}, events.map.with_index(1){|event, i| "#{i}: #{event.event_name}"}]
    end

    def create_review(event_id)
        review_info = @@prompt.collect do
            key(:rating).ask('Please enter your rating for this event (1-10):', required: true)
            key(:review).ask('Please enter your review:')
        end
        review_info[:user_id] = self.id
        Review.create(review_info)
    end

    def events_by_date_range(start_date, end_date)
        user_events = self.user_events.joins(:event_date).where("event_dates.start_date BETWEEN ? AND ?", start_date, end_date)
        display_user_event_details(user_events)
    end

    def change_email(email)
        self.update(email: email)
    end

    def change_username(username)
        if !!Users.find_by(username: username)
            puts "That username is already taken."
        else
            self.update(username: username)
        end
    end

    def change_name(first_name, last_name)
        self.update(first_name: first_name, last_name: last_name)
    end

    def change_city(city)
        self.update(city: city)
    end

    def change_country(country)
        self.update(country: country)
    end

    def delete_account
        Users.destroy(self)
    end

    private

    def display_user_event_details(user_events)
        if user_events.length == 0
            puts "You have no events"
        else
        user_events.each.with_index(1) do |user_event, i|
            puts "Event #{i}: #{user_event.event_date.event.event_name}"
            puts "Event name: #{user_event.event_date.event_date_name}"
            puts "When: #{user_event.event_date.start_date} at #{user_event.event_date.start_time}"
            puts "Where: #{user_event.event_date.venue.venue_name}, #{user_event.event_date.venue.city}, #{user_event.event_date.venue.postcode}"
            puts "--------------------------" if i < user_events.length
        end
    end
    end

    def display_user_review_details(reviews)
        if reviews.length == 0
            puts "You have no reviews"
        else
        reviews.each.with_index(1) do |review, i|
            puts "Event #{i}: #{review.event.event_name}"
            puts "Rating: #{review.rating}"
            puts "Review: #{review.review}"
            puts "--------------------------" if i < reviews.length
        end
    end
    end
end