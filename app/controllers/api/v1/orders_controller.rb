class Api::V1::OrdersController < ApplicationController
  def show
    order = Order.find(params[:id])
    render json: order.to_json
  end
  def pay
    order = Order.find(params[:id])

    tickets = order.pay(params[:token])
    if tickets
      render json: tickets.to_json
    else
      render json: order.errors.full_messages.to_json, status: 500
    end
  end
  def tickets
    tickets = Order.find(params[:id]).tickets
    render json: tickets.to_json
  end
end
