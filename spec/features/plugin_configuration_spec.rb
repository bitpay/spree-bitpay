require 'spec_helper'

feature "plugin configuration", :type => :feature do
	scenario "new payment method" do
		visit new_admin_payment_method_url
		expect(page).should have_selector("#gtwy-type option", text: 'Bitpay')
	end
end
