# encoding: utf-8
# frozen_string_literal: true
# accesses modal popup windows
module ModalHelpers
  def switch_to_new_pop_up
    win = page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
  end

  def close_active_window
    page.driver.browser.close  
    page.driver.browser.switch_to.window(page.driver.browser.window_handles[0])
  end
end
