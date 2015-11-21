# rails-stripe-rspec-tests
##### Testing framework including (eventually) all Stripe processes tested
##### For testing user interactions for subscription memberships, products sales, application webhoooks, etc.

[![Join the chat at https://gitter.im/kathyonu/rails-stripe-rspec-tests](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/kathyonu/rails-stripe-rspec-tests?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This respository of Tests Only is being built specifically from testing our various applications, including our live in production app.  We are collecting all our tests from various apps into one location and sharing this for you to be able to see RSpec and stripe-ruby-mock working tests. (and a few pendings now and then)

These tests are designed to run on Ruby-2.2.3 Rails-4.2.5, and were first based on our rails-stripe-memberships-saas fork, using only Stripe codes, Stripe tests, Stripe webhooks, and we make heavy use the [stripe-ruby-mock](https://github.com/rebelidealist/stripe-ruby-mock) gem to make testing Stripe easy peasy lemon squeezey.

Currently, further tests will begin being added from our development of the [rails-stripe-coupons](https://github.com/RailsApps/rails-stripe-coupons) app.  Wherever tests from one app clash with another, we will develop and name a file for each app.

We have developed[Daniel Kehoe's](https://github.com/RailsApps) original Rails 3.2 app up to current Rails 4.2 and Ruby 2.2.  This was a vintage pure Stripe application we have brought up to current code, and using it in our production app, and now we begin to share those tests. 

Currently, you can see most of these tests in a working application at our [truenorth branch](https://github.com/kathyonu/rails-stripe-membership-saas/tree/truenorth). NOTE of 20151121 : We have several months worth of improvements and additions we will be pushing to the truenorth fork in the very near future. Last I looked we had 382 RSpec tests passing in our production app. When we are doing doing that, this note will disappear.

We are converting the tests to the new usage of RSpec formatting, for example:  

old: expect(response.status).to eq(302)  
new: expect(response.status).to eq 302

old: expect(customer.description).to eq('a customer description')  
new: expect(customer.description).to eq 'a customer description'

We have found two exceptions to not using the parenthesis, they are required for the tests to work.  

When using a **.to match(//)** and  
when matching a Hash:  

  **expect(customer.id).to match(/^test_cus/)**  
  **expect(response.request.cookies).to eq({})**
