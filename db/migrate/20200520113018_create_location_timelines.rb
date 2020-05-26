class CreateLocationTimelines < ActiveRecord::Migration[5.0]
  def change
    create_table :location_timelines do |t|
      t.text :initial_time
      t.text :last_time
      t.text :expected_time
      t.text :actual_time
      t.text :detected_time

      t.timestamps
    end
  end
end
