class OrdersCleanupJob < ApplicationJob
  queue_as :default

  def perform(order)
    order.destroy unless order.closed?
  end
end
