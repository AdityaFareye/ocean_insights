class AddContainerToVessel < ActiveRecord::Migration[5.0]
  def change
    add_reference :vessels, :container, foreign_key: true
  end
end
