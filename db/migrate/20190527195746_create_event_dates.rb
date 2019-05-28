class CreateEventDates < ActiveRecord::Migration[5.0]
  def change
    create_table :event_dates do |t|
      t.string :tm_event_date_id
      t.string :event_date_name
      t.string :url
      t.string :start_date
      t.string :start_time
      t.integer :event_id
      t.integer :venue_id
    end
  end
end
