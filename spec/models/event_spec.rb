require 'rails_helper'

RSpec.describe Event, type: :model do
  before(:each) do
    @event = build(:event)
  end
  it 'is valid with valid attributes' do
    expect(@event).to be_valid
  end
  it 'is not valid without name' do
    @event.name = nil
    expect(@event).not_to be_valid
  end
  it 'is not valid without start date' do
    @event.start_at = nil
    expect(@event).not_to be_valid
  end
  it 'is not valid without end date' do
    @event.end_at = nil
    expect(@event).not_to be_valid
  end
  it 'is not valid without total tickets number' do
    @event.tickets_total = nil
    expect(@event).not_to be_valid
  end
  it 'can be saved' do
    expect { @event.save }.to change { Event.count }
  end
end
