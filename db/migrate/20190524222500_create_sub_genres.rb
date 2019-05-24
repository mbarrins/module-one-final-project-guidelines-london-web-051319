class CreateSubGenres < ActiveRecord::Migration[5.0]
  def change
    create_table :sub_genres do |t|
      t.string :tm_sub_genre_id
      t.string :sub_genre
    end
  end
end
