class CreateVenues < ActiveRecord::Migration[5.0]
  def change
    create_table :venues do |t|
      t.string :tm_venue_id
      t.string :venue
      t.string :url
      t.string :postcode
      t.string :city
      t.string :country
      t.string :address
      t.float :longitude
      t.float :latitude
    end
  end
end
