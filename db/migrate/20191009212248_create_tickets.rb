class CreateTickets < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets do |t|
      t.references :order, null: false, foreign_key: true
      t.string :key, null: false

      t.timestamps
    end
  end
end
