class AddStatusCodeToContainer < ActiveRecord::Migration[5.0]
  def change
    add_column :containers, :status_code, :integer
  end
end
