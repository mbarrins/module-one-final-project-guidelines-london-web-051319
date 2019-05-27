class Venue < ActiveRecord::Base
  has_many :event_dates
  has_many :user_events, through: :event_dates
  has_many :users, through: :user_events
  has_many :reviews, through: :user_events
end