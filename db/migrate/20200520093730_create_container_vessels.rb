class CreateContainerVessels < ActiveRecord::Migration[5.0]
  def change
    create_table :container_vessels do |t|
      t.references :container, foreign_key: true
      t.references :vessel, foreign_key: true

      t.timestamps
    end
  end
end
