require 'rails_helper'

RSpec.describe OrdersCleanupJob, type: :job do
  describe "#perform_later" do
    context 'gets properly enqueued' do
      # to perform "post" request in example
      include RSpec::Rails::RequestExampleGroup

      it 'gets enqueued' do
        ActiveJob::Base.queue_adapter = :test
        expect { OrdersCleanupJob.perform_later("order") }.to have_enqueued_job
      end
      it 'enqueued via /book request for correct time' do
        ActiveJob::Base.queue_adapter = :test

        event = create(:event)
        post "/api/v1/events/#{event.id}/book/1"
        json = JSON.parse(response.body)
        # to catch if request didn't succeed
        expect(response).to have_http_status(200)
        expect(json).not_to be_empty
        @order = Order.find(json["id"])

        expect(OrdersCleanupJob).to have_been_enqueued.with(@order).on_queue("default").at(@order.expires_at)
      end
    end
    context 'performs job' do
      before(:each) do
        event = create(:event)
        @order = build(:order)
        @order.event_id = event.id
        @order.save
      end
      it 'destroys enqueued order' do
        ActiveJob::Base.queue_adapter = :test
        expect { OrdersCleanupJob.perform_now(@order) }.to change { Order.count }
      end
      it 'does not destroy closed orders' do
        ActiveJob::Base.queue_adapter = :test
        @order.closed!
        expect { OrdersCleanupJob.perform_now(@order) }.not_to change { Order.count }
      end
    end
  end
end
