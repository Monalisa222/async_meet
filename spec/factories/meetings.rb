FactoryBot.define do
  factory :meeting do
    association :organization
    association :creator, factory: :user
    title { "Team Sync" }
    description { "Weekly team sync meeting" }
    scheduled_at { 1.day.from_now }
    status { :scheduled }
  end
end
