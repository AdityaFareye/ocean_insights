class CreateContainerLists < ActiveRecord::Migration[5.0]
  def change
    create_table :container_lists do |t|
      t.text :code
      t.text :key
      t.text :shipment_id

      t.timestamps
    end
  end
end
