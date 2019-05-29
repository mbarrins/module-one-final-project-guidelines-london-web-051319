class Genre < ActiveRecord::Base
  has_many :events
  has_many :user_events, through: :events
  has_many :users, through: :user_events
  has_many :reviews, through: :user_events
  has_many :sub_genres
  belongs_to :segment
end