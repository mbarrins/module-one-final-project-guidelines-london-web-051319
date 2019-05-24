class CreateSubGenres < ActiveRecord::Migration[5.0]
  def change
    create_table :sub_genres do |t|
      t.string :tm_id
      t.string :name
    end
  end
end
