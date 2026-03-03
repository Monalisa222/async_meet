FactoryBot.define do
  factory :meeting do
    association :organization
    association :creator, factory: :user
    status { :scheduled }
  end
end
