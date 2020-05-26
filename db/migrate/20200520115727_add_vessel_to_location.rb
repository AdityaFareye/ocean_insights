class AddVesselToLocation < ActiveRecord::Migration[5.0]
  def change
    add_reference :locations, :vessel, foreign_key: true
  end
end
