# Read about factories at https://github.com/thoughtbot/factory_girl
# Traits allow you to group attributes together and then apply them to any factory.
# Reference : https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md
FactoryGirl.define do
  factory :visitor do
    email 'visitor@example.com'

    trait :visitor do
      role 'visitor'
    end
  end
end
