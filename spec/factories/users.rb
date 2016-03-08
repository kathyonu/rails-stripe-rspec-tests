# Read about factories at https://github.com/thoughtbot/factory_girl
# Traits allow you to group attributes together and then apply them to any factory.
# Reference : https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md

FactoryGirl.define do
  factory :user do
    name 'Test User'
    email 'test@example.com'
    password '8charmin'
    password_confirmation '8charmin'
    # required if the Devise Confirmable module is used
    # confirmed_at Time.now

    trait :admin do
      role 'admin'
    end
  end
end
