class CreateGenres < ActiveRecord::Migration[5.0]
  def change
    create_table :genres do |t|
      t.string :tm_genre_id
      t.string :genre
    end
  end
end
