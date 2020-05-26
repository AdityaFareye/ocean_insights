class AddBillOfLadingToContainerList < ActiveRecord::Migration[5.0]
  def change
    add_column :container_lists, :bill_of_lading, :string
    add_column :container_lists, :bill_of_lading_bookmark_id, :string
  end
end
