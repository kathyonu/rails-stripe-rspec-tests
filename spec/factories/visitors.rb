# frozen_string_literal: true
# Read about factories at https://github.com/thoughtbot/factory_girl
# Traits allow you to group attributes together and then apply them to any factory.
# Reference : https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md
# Visitor allows entry to one page with email, which is scubscribed to MailChimp list
FactoryGirl.define do
  factory :visitor do
    email 'visitor@example.com'

    trait :visitor do
      role 'visitor'
    end
  end
end
