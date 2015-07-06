# rails-stripe-rspec-tests
##### Testing framework including (eventually) all Stripe processes tested
##### For testing user interactions for subscription memberships, products sales, application webhoooks, etc.

This respository of Tests Only is being built specifically for testing our live in production app.

These tests are designed to test the Ruby 2.2.2 on Rails 4.2.1 rails-stripe-memberships-saas using only Stripe codes, Stripe tests, Stripe webhooks, and we make heavy use the [stripe-ruby-mock](https://github.com/rebelidealist/stripe-ruby-mock) gem to make testing Stripe easy peasy lemon squeezy.

The original 3.2 branch of the membership app by [Daniel Kehoe](https://github.com/RailsApps) can be found there. We have developed this vintage pure Stripe application to current codes, and now we begin to share those tests. 

Currently, you can see these working tests in the application at [testsformaster branch](https://github.com/kathyonu/rails-stripe-membership-saas/tree/testsformaster)
