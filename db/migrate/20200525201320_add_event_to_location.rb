class AddEventToLocation < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :event_raw, :text
    add_column :locations, :event_time, :text
    add_column :locations, :event_type_code, :text
    add_column :locations, :event_type_name, :text
  end
end
