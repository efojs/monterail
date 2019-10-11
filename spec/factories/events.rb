FactoryBot.define do
  factory :event do
    name { Faker::Music.band }
    start_at { @start_date = Time.now.in(rand(-10800..600000)) }
    end_at { @start_date.in(rand(1800..10800)) }
    tickets_total { rand(100..5000) }
    tickets_sold { 0 }
    ticket_price { rand(0..1500) }
  end
end
