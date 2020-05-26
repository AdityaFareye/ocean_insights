class AddNextPortToVesselLog < ActiveRecord::Migration[5.0]
  def change
    add_column :vessel_logs, :next_port, :text
  end
end
