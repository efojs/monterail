class Event < ApplicationRecord
  has_many :orders
  validates_presence_of :name, :start_at, :end_at, :tickets_total
end
