class AddContainerIdToContainerData < ActiveRecord::Migration[5.0]
  def change
    add_reference :container_data, :container, foreign_key: true
  end
end
