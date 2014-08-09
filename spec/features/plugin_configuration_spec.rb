require 'spec_helper'

feature "plugin configuration", :type => :feature do
	scenario "load page" do 
		login_admin
		visit new_admin_payment_method_path
		expect(page).to have_selector('#gtwy-type option[value="Spree::PaymentMethod::Bitpay"]')
	end

	scenario "add new" do
		pending
	end	
end
