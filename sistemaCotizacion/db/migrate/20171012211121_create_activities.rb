class CreateActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :activities do |t|
      t.string :name, limit: 50
      t.string :description, limit: 200
      t.integer :quantity
      t.integer :unit_value
      t.integer :value_meter
      t.references :activity_type, foreign_key: true
      t.references :construction_type, foreign_key: true

      t.timestamps
    end
  end
end
