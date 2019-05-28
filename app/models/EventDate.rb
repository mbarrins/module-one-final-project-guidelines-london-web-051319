class EventDate < ActiveRecord::Base
  has_many :user_events
  has_many :users, through: :user_events
  belongs_to :venue
  belongs_to :event
end