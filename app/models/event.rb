class Event < ActiveRecord::Base
    has_many :user_events
    has_many :users, through: :user_events
    has_many :reviews, through: :user_events
    has_many :event_dates
    belongs_to :segment
    belongs_to :genre
    belongs_to :sub_genre
end