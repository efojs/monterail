class Ticket < ApplicationRecord
  belongs_to :order

  validates_presence_of :order_id, :key

  before_save :close_order

  def close_order
    # to ensure orders closure
    if self.order.open?
      raise StandardError, "Order failed to close" unless self.order.closed!
    end
  end
end
