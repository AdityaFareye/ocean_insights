class AddTargetPortToVessel < ActiveRecord::Migration[5.0]
  def change
    add_column :vessels, :target_port_code, :text
    add_column :vessels, :target_port_name, :text
  end
end
