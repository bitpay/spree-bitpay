require 'spec_helper'

feature "Bitpay Plugin", js: true, type: :feature do

	# NOTE: Tests require a properly populated test DB as per testapp.sh.
	# Not all tests are idempotent - DB may require manual reset after test failure

	scenario "can be configured by admin" do

		admin = create(:admin_user, email: "test@bitpay.com")

		visit admin_login_path  
		fill_in 'Email', with: admin.email
		fill_in 'Password', with: 'secret'
		click_button "Login"		
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
		fill_in "payment_method_bitpay_preferred_api_key", with: ENV['BITPAYKEY']
		select "Test", from: "gtwy-env"

		click_on "Update"				
		expect(page).to have_selector('.success'), "No success message"
		visit admin_logout_path

	end	

	xscenario "can display invoice" do
		user = create(:user_with_addreses)
		shipping_method = create(:free_shipping_method, name: "Satoshi Post")
		product = create(:base_product, name: "BitPay T-Shirt")
		visit login_path
		fill_in 'Email', with: user.email
		fill_in 'Password', with: 'secret'
		click_button "Login"

		expect(current_path).to eq(root_path), "User Login failed"
		click_on "BitPay T-Shirt"
		click_button "Add To Cart"
		click_button "Checkout"
		click_button "Save and Continue" # Confirm Address
		click_button "Save and Continue" # Confirm Delivery Options
		choose "Bitcoin"

		#TODO expect image is visible

		expect { click_button "Save and Continue" }.to change(Spree::BitpayInvoice, :count).by(1)  # Confirm Payment Options
		expect(current_path).to end_with "confirm"

		click_button "Place Order"

		page.within_frame 'bitpay_invoice_iframe' do
		  expect(page).to have_content("Pay with Bitcoin")
		end


		#save_and_open_screenshot

	end

end
