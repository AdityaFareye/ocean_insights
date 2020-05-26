class AddAisToVessel < ActiveRecord::Migration[5.0]
  def change
    add_column :vessels, :ais, :text
  end
end
