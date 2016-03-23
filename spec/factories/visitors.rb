# frozen_string_literal: true
# Read about factories at https://github.com/thoughtbot/factory_girl
# Traits allow you to group attributes together and then apply them to any factory.
# Reference : https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md
FactoryGirl.define do
  factory :visitor do
    # name 'Visitor User' # not required
    email 'visitor@example.com'
    # password 'changemenow' # not required
    # password_confirmation 'changemenow' # not required

    # required if the Devise Confirmable module is used
    # confirmed_at Time.now

    trait :visitor do
      role 'visitor'
    end
  end
end
