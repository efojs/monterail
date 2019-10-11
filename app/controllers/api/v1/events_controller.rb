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
    order = Order.new(event_id: params[:id], tickets_amount: params[:amount])
    if order.save
      render json: order.to_json
    else
      render json: order.errors.full_messages.to_json, status: 500
    end

  end
end
