class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.integer :location_type
      t.text :code
      t.text :raw
      t.text :location_type_name
      t.text :port_code
      t.text :port_name
      t.text :lat
      t.text :long
      t.text :timezoe

      t.timestamps
    end
  end
end
