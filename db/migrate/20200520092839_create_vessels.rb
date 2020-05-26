class CreateVessels < ActiveRecord::Migration[5.0]
  def change
    create_table :vessels do |t|
      t.text :number
      t.text :name
      t.text :imo

      t.timestamps
    end
  end
end
