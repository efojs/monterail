class ChangeDurationToEndDateInEvent < ActiveRecord::Migration[6.0]
  def change
    change_table :events do |t|
      t.remove :duration, :bigint
      t.rename :date, :start_at
      t.datetime :end_at
    end
  end
end
