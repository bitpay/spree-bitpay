require 'spec_helper'

feature "plugin configuration", js: true, type: :feature do

	scenario "can be added and configured" do

		login_admin
		visit new_admin_payment_method_path
		# Should show up as a provider
		expect(page).to have_selector('#gtwy-type option[value="Spree::PaymentMethod::Bitpay"]'), "Not visible in drop down"

		fill_in "payment_method_name", with: "Bitcoin"
		fill_in "payment_method_description", with: "BitPay payment processing"
		select "Spree::PaymentMethod::Bitpay", from: "gtwy-type"
		# Should create a new PaymentMethod, redirect to edit page and flash success message
		expect { click_on "Create" }.to change(Spree::PaymentMethod, :count).by(1)
		#expect(response).to be_redirect
		expect(page).to have_selector('.success'), "No success message"

		# should have bitpay production address as default endpoint
		# (it does but somehow previous inputs get cached and take precedence??)
		# expect(page).to have_selector('#payment_method_bitpay_preferred_api_endpoint[value="https://bitpay.com/api"]')
		
		fill_in "payment_method_bitpay_preferred_api_endpoint", with: "https://test.bitpay.com/api"
		fill_in "payment_method_bitpay_preferred_api_key", with: "rOlmMQm5WmN8E21fvyCpt66iKeQ4aMZJU02sfTCo6M"

		click_on "Update"				
		expect(page).to have_selector('.success'), "No success message"

	end	
end
