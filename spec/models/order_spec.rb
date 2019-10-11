require 'rails_helper'

RSpec.describe Order, type: :model do
  before(:each) do
    event = create(:event)
    @order = build(:order)
    @order.event_id = event.id
  end
  it 'is valid with valid attributes' do
    expect(@order).to be_valid
  end
  it 'is not valid without event ID' do
    @order.event_id = nil
    expect(@order).not_to be_valid
  end
  it 'is not valid without tickets amount' do
    @order.tickets_amount = nil
    expect(@order).not_to be_valid
  end
  it 'is not valid with ticket amount 0' do
    @order.tickets_amount = 0
    expect(@order).not_to be_valid
  end
  it 'can be saved' do
    expect { @order.save }.to change { Order.count }
  end
  it 'can change status to closed' do
    @order.save
    expect { @order.closed! }.to change(@order, :status).from("open").to("closed")
  end
  it 'can change status back to open' do
    @order.save
    @order.closed!
    expect { @order.open! }.to change(@order, :status).from("closed").to("open")
  end
  context "when deleted" do
    it 'restores events sold tickets' do
      @order.save
      expect { @order.destroy }.to change { Event.find(@order.event_id).tickets_sold }
    end
  end
end
