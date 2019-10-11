class Api::V1::EventsController < ApplicationController
  def index
    events = Event.all
    render json: events.to_json
  end

  def show
    event = Event.find(params[:id])
    render json: event.to_json
  end

  def book
    event = Event.find(params[:id])
    if event.end_at > Time.now
      order = Order.new(event_id: event.id, tickets_amount: params[:amount])
      if order.save
        OrdersCleanupJob.set(wait_until: order.expires_at).perform_later(order)
        render json: order.to_json
      else
        render json: order.errors.full_messages.to_json, status: 500
      end
    else
      raise StandardError, "Event is already over"
    end
  end
end
