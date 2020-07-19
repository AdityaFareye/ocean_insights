class AddSurscriptionIdToContainerList < ActiveRecord::Migration[5.0]
  def change
    add_column :container_lists, :subscription_id, :string
  end
end
