require 'rails_helper'

# to not raise Rails' development exceptions
require 'exceptions'

RSpec.describe "Events API", type: :request do
  describe 'GET requests' do
    context "/events" do
      context "all:" do
        context "when several events exist" do
          before(:each) do
            @events = create_list(:event, 10)
            get "/api/v1/events"
          end
          it 'responds with 200 and proper amount of events' do
            expect(response).to have_http_status(200)
            expect(json).not_to be_empty
            expect(json.length).to eq(@events.length)
          end
        end
        context "when there are no events" do
          before(:each) do
            get "/api/v1/events"
          end
          it 'responds with 200 and empty array' do
            expect(response).to have_http_status(200)
            expect(json).to be_empty
          end
        end
      end
      context 'one:' do
        context 'exists' do
          before(:each) do
            @event = create(:event)
            get "/api/v1/events/#{@event.id}/"
          end
          it 'responds with 200 and proper attributes' do
            expect(response).to have_http_status(200)
            expect(json).not_to be_empty
            expect(json['id']).to eq(@event.id)
            expect(json['tickets_total']).to eq(@event.tickets_total)
          end
        end

        context "does not exist" do
          before(:each) do
            get "/api/v1/events/1/"
          end
          it 'responds with 404' do
            expect(response).to have_http_status(404)
          end
        end
      end
    end

    context '/orders' do
      context "all:" do
        it 'responds with 404' do
          get "/api/v1/orders/"
          expect(response).to have_http_status(404)
        end
      end
      context 'one:' do
        context "exists" do
          before(:each) do
            @order = build(:order)
            @event = create(:event)
            @order.event_id = @event.id
            @order.save
            get "/api/v1/orders/#{@order.id}/"
          end
          it 'responds with 200 and proper attributes' do
            expect(response).to have_http_status(200)
            expect(json).not_to be_empty
            expect(json['id']).to eq(@order.id)
            expect(json['status']).to eq("open")
            expect(json['event_id']).to eq(@event.id)
            expect(json['tickets_amount']).to eq(@order.tickets_amount)
            expect(json['expires_at']).to eq(JSON.parse(@order.expires_at.to_json))
          end
          it 'expires in less than 15 minutes' do
            expires_at = Time.zone.parse(json['expires_at'])
            time_left = expires_at - Time.now
            expect(time_left > 0 && time_left < 900).to eq true
          end
        end

        context 'order does not exist' do
          before(:each) do
            get "/api/v1/orders/1/"
          end
          it 'responds with 404' do
            expect(response).to have_http_status(404)
          end
        end
      end
    end
    context "/tickets" do
      context "all:" do
        before(:each) do
          event = create(:event)
          @order = build(:order)
          @order.event_id = event.id
          @order.save
        end
        context 'when tickets exist' do
          before(:each) do
            tickets = build_list(:ticket, 3)
            tickets.each do |t|
              t.order_id = @order.id
              t.save
            end
            get "/api/v1/orders/#{@order.id}/tickets"
          end
          it 'returns the list of tickets' do
            expect(response).to have_http_status(200)
            expect(json).not_to be_empty
            expect(json.length).to eq(3)
          end
        end
        context 'when order has no tickets' do
          before(:each) do
            get "/api/v1/orders/#{@order.id}/tickets"
          end
          it 'responds with 200 and empty array' do
            expect(response).to have_http_status(200)
            expect(json).to be_empty
          end
        end
      end
    end
  end

  describe 'POST requests' do
    context '/book' do
      context "all requested tickets available" do
        before(:each) do
          @event = build(:event)
          @event.tickets_total = 100
          @event.tickets_sold = 90
          @event.save
          @tickets_to_buy = 5
          post "/api/v1/events/#{@event.id}/book/#{@tickets_to_buy}"
        end
        it 'responds with 200 and requested amount of tickets' do
          expect(response).to have_http_status(200)
          expect(json).not_to be_empty
          expect(json["tickets_amount"]).to eq(@tickets_to_buy)
        end
        it 'reduces amount of available tickets' do
          get "/api/v1/events/#{@event.id}"
          expect(json["tickets_sold"]).to eq(95)
        end
      end
      context 'requested amount of tickets not available' do
        before(:each) do
          @event = build(:event)
          @event.tickets_total = 100
          @event.tickets_sold = 90
          @event.save
          @tickets_to_buy = 15
          post "/api/v1/events/#{@event.id}/book/#{@tickets_to_buy}"
        end
        it 'responds with 500 and proper error message' do
          expect(response).to have_http_status(500)
          expect(json).not_to be_empty
          expect(response.body).to match(/Requested amount of tickets \(#{@tickets_to_buy}\) not available. Only #{10} left/)
        end
      end
      context 'event if over' do
        before(:each) do
          @event = build(:event)
          @event.end_at = Time.now
          @event.save
          post "/api/v1/events/#{@event.id}/book/#{1}"
        end
        it 'responds with 500' do
          expect(response).to have_http_status(500)
          expect(response.body).to match(/Event is already over/)
        end
      end
    end

    context '/pay' do
      before(:each) do
        event = build(:event)
        event.save
        post "/api/v1/events/#{event.id}/book/#{2}"
        @order = json
      end
      context 'succeeded' do
        before(:each) do
          post "/api/v1/orders/#{@order['id']}/pay/ok"
        end
        it 'responds with 200, requested amount of tickets and order closed' do
          expect(response).to have_http_status(200)
          expect(json).not_to be_empty
          expect(json.length).to eq(@order['tickets_amount'])

          order = Order.find(@order['id'])
          expect(order.status).to eq("closed")
        end
      end
      context 'succeeded, but order expired due to payment delay' do
        before(:each) do
          post "/api/v1/orders/#{@order['id']}/pay/expired"
        end
        it 'responds with 500 and proper message' do
          expect(response).to have_http_status(500)
          expect(response.body).to match(/During purchase something went wrong, no tickets bought, we returned you your money/)
        end
      end
      context 'failed' do
        context "order is closed" do
          before(:each) do
            order = Order.find(@order['id'])
            order.closed!
            post "/api/v1/orders/#{@order['id']}/pay/ok"
          end
          it 'responds with 500 and proper message' do
            expect(response).to have_http_status(500)
            expect(response.body).to match(/Order is already closed/)
          end
        end
        context "reservation expired / no such order" do
          before(:each) do
            post "/api/v1/orders/#{2}/pay/ok"
          end
          it 'responds with 404' do
            expect(response).to have_http_status(404)
          end
        end
        context 'payment failed' do
          before(:each) do
            Order.find(@order['id']).open!
          end
          context 'due to card error' do
            it 'responds with 500 and proper error message' do
              post "/api/v1/orders/#{@order['id']}/pay/card_error"
              expect(response).to have_http_status(500)
              expect(response.body).to match(/Your card has been declined/)
            end
          end
          context 'due to payment error' do
            it 'responds with 500 and proper error message' do
              post "/api/v1/orders/#{@order['id']}/pay/payment_error"
              expect(response).to have_http_status(500)
              expect(response.body).to match(/Something went wrong with your transaction/)
            end
          end
        end
      end
    end
  end

  def json
    JSON.parse(response.body)
  end
end
