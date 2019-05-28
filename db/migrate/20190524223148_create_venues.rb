class CreateVenues < ActiveRecord::Migration[5.0]
  def change
    create_table :venues do |t|
      t.string :tm_venue_id
      t.string :venue_name
      t.string :url
      t.string :postcode
      t.string :city
      t.string :country
    end
  end
end
