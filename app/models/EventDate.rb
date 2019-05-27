class EventDate < ActiveRecord::Base
  has_many :user_events
  has_many :users, through: :user_events
  has_many :reviews, through: :user_events
  belongs_to :venue
end