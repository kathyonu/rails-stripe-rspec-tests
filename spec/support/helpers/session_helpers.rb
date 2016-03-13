module Features
  module SessionHelpers
    def sign_up_silver(name, email, password, confirmation)
      visit '/users/sign_up?plan=silver'
      fill_in :user_name, with: name
      fill_in :user_email, with: email
      fill_in :user_password, with: password
      fill_in :user_password_confirmation, with: confirmation
      fill_in :card_number, with: '4242424242424242'
      fill_in :card_code, with: '123'
      select 10, from: 'card_month'
      select 2020, from: 'card_year'
      click_button 'Sign up'
    end

    def sign_up_gold(name, email, password, confirmation)
      visit '/users/sign_up?plan=gold'
      fill_in :user_name, with: name
      fill_in :user_email, with: email
      fill_in :user_password, with: password
      fill_in :user_password_confirmation, with: confirmation
      fill_in :card_number, with: '4242424242424242'
      fill_in :card_code, with: '123'
      select 12, from: 'card_month'
      select 2021, from: 'card_year'
      click_button 'Sign up'
    end

    def sign_up_platinum(name, email, password, confirmation)
      visit '/users/sign_up?plan=platinum'
      fill_in :user_name, with: name
      fill_in :user_email, with: email
      fill_in :user_password, with: password
      fill_in :user_password_confirmation, with: confirmation
      fill_in :card_number, with: '4242424242424242'
      fill_in :card_code, with: '123'
      select 12, from: 'card_month'
      select 2022, from: 'card_year'
      click_button 'Sign up'
    end

    def sign_up_board(name, email, password, confirmation)
      visit '/users/sign_up?plan=board'
      fill_in 'Name', with: name
      fill_in 'Email', with: email
      fill_in :user_password, with: password
      fill_in :user_password_confirmation, with: confirmation
      fill_in :card_number, with: '4242424242424242'
      fill_in :card_code, with: '123'
      select 12, from: 'card_month'
      select 2022, from: 'card_year'
      click_button 'Sign up'
    end

    def sign_up_silver_sans_email(name, email, password, confirmation)
      visit '/users/sign_up?plan=silver'
      fill_in :user_name, with: name
      fill_in :user_email, with: email
      fill_in :user_password, with: password
      fill_in :user_password_confirmation, with: confirmation
      fill_in :card_number, with: '4242424242424242'
      fill_in :card_code, with: '123'
      select 10, from: 'card_month'
      select 2020, from: 'card_year'
      click_button 'Sign up'
    end

    def sign_up_silver_sans_password(name, email, password, confirmation)
      visit '/users/sign_up?plan=silver'
      fill_in :user_name, with: name
      fill_in :user_email, with: email
      fill_in :user_password, with: password
      fill_in :user_password_confirmation, with: confirmation
      fill_in :card_number, with: '4242424242424242'
      fill_in :card_code, with: '123'
      select 10, from: 'card_month'
      select 2020, from: 'card_year'
      click_button 'Sign up'
    end

    def sign_up(name, email, password, confirmation)
      visit new_user_registration_path
      fill_in :user_name, with: name
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      fill_in 'Password confirmation', with: confirmation
      click_button 'Sign up'
    end

    # duplicate of above, used in different app
    def sign_up_with(name, email, password, confirmation)
      visit new_user_registration_path
      fill_in :user_name, with: name
      fill_in :user_email, with: email
      fill_in :user_password, with: password
      fill_in :user_password_confirmation, with: confirmation
      click_button 'Sign up'
    end

    def sign_in(email, password)
      visit new_user_session_path
      fill_in 'user_email', with: email
      fill_in 'user_password', with: password
      click_button 'Sign in'
    end

    def sign_in_user(email, password)
      visit new_user_session_path
      fill_in 'user_email', with: email
      fill_in 'user_password', with: password
      click_button 'Sign in'
    end

    def sign_out
      visit '/users/sign_out'
    end

    # used in spec/controllers/visitors_controller_spec.rb
    # root_path = /visitors/new
    def visitor_sign_up_for_ebook(visitor_email)
      visit root_path
      fill_in 'Email', with: visitor_email
      # fill_in 'Password', with: password # not used, not required
      # fill_in 'Password confirmation', with: confirmation # not used, not required
      click_button 'Take a Trip Across the Letters Trestle'
    end

    def sign_in_visitor
      visitor = FactoryGirl.create(:visitor, email: 'new@example.com')
      visit root_path
      fill_in 'Email', with: visitor.email
      click_button 'Take a Trip Across the Letters Trestle'
    end
  end
end
