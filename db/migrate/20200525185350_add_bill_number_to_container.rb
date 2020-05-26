class AddBillNumberToContainer < ActiveRecord::Migration[5.0]
  def change
    add_column :containers, :bill_number, :text
  end
end
