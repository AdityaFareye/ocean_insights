class CreateOceanInsightGeoTracks < ActiveRecord::Migration[5.0]
  def change
    create_table :ocean_insight_geo_tracks do |t|
      t.string :track_id
      t.string :transport_mode_verbose
      t.string :pos_source_verbose
      t.string :latitude
      t.string :longitude
      t.string :vessel_speed_over_ground
      t.string :vessel_course_over_ground
      t.string :vessel_shipname
      t.string :vessel_callsign

      t.timestamps
    end
  end
end
