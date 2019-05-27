class CreateEventDates < ActiveRecord::Migration[5.0]
  def change
    def change
      create_table :events do |t|
        t.string :tm_event_dates_id
        t.string :event_dates_name
        t.string :url
        t.string :sales_start_date
        t.string :sales_end_date
        t.string :start_date
        t.string :start_time
        t.integer :event_id
        t.integer :venue_id
  
      end
    end
  end
end