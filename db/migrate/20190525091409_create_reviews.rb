class CreateReviews < ActiveRecord::Migration[5.0]
  def change
    create_table :reviews do |t|
      t.integer :user_event_id
      t.integer :rating
      t.text :review
    end
  end
end
