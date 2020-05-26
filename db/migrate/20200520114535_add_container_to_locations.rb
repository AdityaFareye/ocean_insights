class AddContainerToLocations < ActiveRecord::Migration[5.0]
  def change
    add_reference :locations, :container, foreign_key: true
  end
end
