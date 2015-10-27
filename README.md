# rails-stripe-rspec-tests
##### Testing framework including (eventually) all Stripe processes tested
##### For testing user interactions for subscription memberships, products sales, application webhoooks, etc.

[![Join the chat at https://gitter.im/kathyonu/rails-stripe-rspec-tests](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/kathyonu/rails-stripe-rspec-tests?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This respository of Tests Only is being built specifically for testing our various applications, including our live in production app.

These tests are designed to run on Ruby-2.2.3 Rails-4.2.4, and were first based on our rails-stripe-memberships-saas fork, using only Stripe codes, Stripe tests, Stripe webhooks, and we make heavy use the [stripe-ruby-mock](https://github.com/rebelidealist/stripe-ruby-mock) gem to make testing Stripe easy peasy lemon squeezey.

Further tests are being added from our development of the [rails-stripe-coupons](https://github.com/RailsApps/rails-stripe-coupons).  Wherever tests from one app clash with another, we will develop and name a file for each app.

The original 3.2 branch of the membership app by [Daniel Kehoe](https://github.com/RailsApps) can be found there. We have developed this vintage pure Stripe application to current codes, and now we begin to share those tests. 

Currently, you can see most of these tests in a working application at our [truenorth branch](https://github.com/kathyonu/rails-stripe-membership-saas/tree/truenorth).

I created this respository to collect our tests as we develop them, and to share with those learning to test, using RSpec and the stripe-ruby-mock gem.