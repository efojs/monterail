class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :name
      t.datetime :date
      t.bigint :duration
      t.integer :tickets_total
      t.integer :tickets_sold
      t.decimal :ticket_price

      t.timestamps
    end
  end
end
