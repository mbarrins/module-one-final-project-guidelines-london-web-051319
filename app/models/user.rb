class User < ActiveRecord::Base
    has_many :user_events
    has_many :events, through: :user_events
    has_many :event_dates, through: :user_events
    has_many :reviews, through: :user_events

    def future_user_events
        self.user_events.joins(:event_date).where("event_dates.start_date >= #{Date.today}")
    end

    def past_user_events
        self.user_events.joins(:event_date).where("event_dates.start_date < #{Date.today}")
    end

    def events_by_date_range(start_date, end_date)
        self.user_events.joins(:event_date).where("event_dates.start_date BETWEEN ? AND ?", start_date, end_date)
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

end