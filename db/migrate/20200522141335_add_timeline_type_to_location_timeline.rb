class AddTimelineTypeToLocationTimeline < ActiveRecord::Migration[5.0]
  def change
    add_column :location_timelines, :timeline_type, :text
  end
end
