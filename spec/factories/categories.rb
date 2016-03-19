# frozen_string_literal: true
# Read about factories at https://github.com/thoughtbot/factory_girl
# Traits allow you to group attributes together and then apply them to any factory.
# Reference : https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md
FactoryGirl.define do
  factory :category do
    name 'MyString'
  end
end
