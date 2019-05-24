class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :tm_event_id
      t.string :event_name
      t.string :url
      t.string :sales_start_date
      t.string :sales_end_date
      t.string :start_date
      t.string :start_time
      t.integer :venue_id
      t.integer :segment_id
      t.integer :genre_id
      t.integer :sub_genre_id

    end
  end
end
