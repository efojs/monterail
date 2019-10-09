class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.references :event, null: false, foreign_key: true
      t.integer :tickets_amount, null: false
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
