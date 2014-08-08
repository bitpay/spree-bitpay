require 'spec_helper'

feature "plugin configuration", :type => :feature do
	scenario "load page" do
  
  admin = create(:admin_user)

  visit admin_login_path
  fill_in 'Email', with: admin.email
  fill_in 'Password', with: 'secret'
  puts "yo I'm at #{current_url} 2"
  click_on "Login"
  binding.pry
  puts "yo I'm at #{current_url} 3"


		visit new_admin_payment_method_path
  puts "yo I'm at #{current_url} 4"
		expect(page).to have_selector('#gtwy-type option[value="Spree::PaymentMethod::Bitpay"]')
	end

	scenario "add new" do
		pending
	end	
end
