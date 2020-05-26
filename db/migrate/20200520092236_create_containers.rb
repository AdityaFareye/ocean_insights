class CreateContainers < ActiveRecord::Migration[5.0]
  def change
    create_table :containers do |t|
      t.text :number
      t.text :container_type
      t.decimal :weight
      t.text :iso
      t.text :name
      t.text :status
      t.text :carrier_name
      t.text :carrier_scac

      t.timestamps
    end
  end
end
