class Order < ApplicationRecord
  enum status: [ :open, :closed ]
  belongs_to :event
  has_many :tickets
end
