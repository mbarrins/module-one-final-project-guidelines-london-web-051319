class CreateSegments < ActiveRecord::Migration[5.0]
  def change
    create_table :segments do |t|
      t.string :tm_segment_id
      t.string :segment_name
    end
  end
end
