class UserEvent < ActiveRecord::Base
    belongs_to :user
    belongs_to :event
    belongs_to :event_date
    has_one :review
    
    def change_date

    end

    
end