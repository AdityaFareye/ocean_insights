class AddNameToLocation < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :name, :text
  end
end
