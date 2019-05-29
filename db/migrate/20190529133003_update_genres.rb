class UpdateGenres < ActiveRecord::Migration[5.0]
  def change
    change_table :genres do |t|
      t.integer :segment_id
    end
  end
end
