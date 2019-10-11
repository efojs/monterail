require 'rails_helper'

RSpec.describe Ticket, type: :model do
  before(:each) do
    event = create(:event)
    order = build(:order)
    order.event_id = event.id
    order.save
    @ticket = build(:ticket)
    @ticket.order_id = order.id
  end
  it 'is valid with valid attributes' do
    expect(@ticket).to be_valid
  end
  it 'is not valid without order ID' do
    @ticket.order_id = nil
    expect(@ticket).not_to be_valid
  end
  it 'is not valid without key' do
    @ticket.key = nil
    expect(@ticket).not_to be_valid
  end
  it 'can be saved' do
    expect { @ticket.save }.to change { Ticket.count }
  end
end
