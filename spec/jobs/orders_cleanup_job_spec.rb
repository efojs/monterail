require 'rails_helper'

RSpec.describe OrdersCleanupJob, type: :job do
  describe "#perform_later" do
    context 'gets properly enqueued' do
      it 'gets enqueued' do
        ActiveJob::Base.queue_adapter = :test
        expect { OrdersCleanupJob.perform_later("order") }.to have_enqueued_job
      end
      it 'enqueued for correct time' do
        ActiveJob::Base.queue_adapter = :test
        time = Time.now
        expect {
          OrdersCleanupJob.set(wait_until: time+900).perform_later("order")
        }.to have_enqueued_job.with("order").on_queue("default").at(time + 900)
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
