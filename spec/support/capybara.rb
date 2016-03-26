# frozen_string_literal: true
# to allow CSS and Javascript to be loaded when we use save_and_open_page, the
# development server must be running at localhost:3000 as specified below or
# wherever you want. See original issue here:
# https://github.com/jnicklas/capybara/pull/609
# and final resolution here:
# https://github.com/jnicklas/capybara/pull/958
# Ref : http://stackoverflow.com/questions/16137916/save-and-open-page-has-stopped-serving-up-my-css
Capybara.asset_host = 'http://localhost:3000'
