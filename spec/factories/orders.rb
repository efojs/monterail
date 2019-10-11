FactoryBot.define do
  factory :order do
    status { :open }
    event_id { nil }
    tickets_amount { rand(1..10) }
  end
end
