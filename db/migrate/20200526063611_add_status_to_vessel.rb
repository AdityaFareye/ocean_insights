class AddStatusToVessel < ActiveRecord::Migration[5.0]
  def change
    add_column :vessels, :status, :text
    add_column :vessels, :status_code, :text
  end
end
