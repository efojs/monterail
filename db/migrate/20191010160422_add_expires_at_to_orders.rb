class AddExpiresAtToOrders < ActiveRecord::Migration[6.0]
  # SQLite fills new with NULL, but we want to restrict
  # to work it around
  # https://stackoverflow.com/a/6710280/2936673
  # https://guides.rubyonrails.org/active_record_migrations.html
  def up
    add_column :orders, :expires_at, :datetime, precision: 6
    change_column :orders, :expires_at, :datetime, precision: 6, null: false
  end
  def down
    remove_column :orders, :expires_at, :datetime, precision: 6
  end
end
