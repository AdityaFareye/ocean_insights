class AddSizeToContainer < ActiveRecord::Migration[5.0]
  def change
    add_column :containers, :size, :text
  end
end
