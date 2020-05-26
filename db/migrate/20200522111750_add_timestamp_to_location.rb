class AddTimestampToLocation < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :timestamp, :text
  end
end
