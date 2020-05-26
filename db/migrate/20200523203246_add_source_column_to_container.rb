class AddSourceColumnToContainer < ActiveRecord::Migration[5.0]
  def change
    add_column :containers, :source, :text
  end
end
