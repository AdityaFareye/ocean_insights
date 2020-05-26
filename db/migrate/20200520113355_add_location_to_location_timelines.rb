class AddLocationToLocationTimelines < ActiveRecord::Migration[5.0]
  def change
    add_reference :location_timelines, :location, foreign_key: true
  end
end
