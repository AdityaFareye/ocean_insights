class CreateVesselLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :vessel_logs do |t|
      t.text :log
      t.references :vessel, foreign_key: true

      t.timestamps
    end
  end
end
