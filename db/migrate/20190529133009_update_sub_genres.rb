class UpdateSubGenres < ActiveRecord::Migration[5.0]
  def change
    change_table :sub_genres do |t|
      t.integer :genre_id
    end
  end
end
