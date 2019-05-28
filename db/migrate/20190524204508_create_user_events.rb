class CreateUserEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :user_events do |t|
      t.integer :user_id
      t.integer :event_date_id
    end
  end
end
