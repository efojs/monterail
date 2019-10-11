FactoryBot.define do
  factory :ticket do
    order_id { nil }
    key { "some string".hash.to_s + SecureRandom.alphanumeric(5) }
  end
end
