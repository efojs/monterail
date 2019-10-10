class AddSumToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :sum, :decimal, default: 0
  end
end
