require 'spec_helper'

feature "Creating a new BitPay Payment Method", js: true, type: :feature do
  scenario "we see an 'Authenticate with BitPay' form" do
    admin = create(:admin_user, email: "integrations@bitpay.com")
    visit spree.admin_login_path  
    fill_in 'Email', with: admin.email
    fill_in 'Password', with: 'secret'
    click_button "Login"    
    visit spree.new_admin_payment_method_path
    fill_in "payment_method_name", with: "Bitcoin"
    select "Spree::PaymentMethod::BitPay", from: "gtwy-type"
    click_on("Create")
    expect(page).to have_content("AUTHENTICATE WITH BITPAY"), "No authentication form"
  end

  scenario "has a dropdown with 'test' and 'live' options" do
    admin = create(:admin_user, email: "integrations@bitpay.com")
    visit spree.admin_login_path  
    fill_in 'Email', with: admin.email
    fill_in 'Password', with: 'secret'
    click_button "Login"    
    visit spree.new_admin_payment_method_path
    fill_in "payment_method_name", with: "Bitcoin"
    select "Spree::PaymentMethod::BitPay", from: "gtwy-type"
    click_on("Create")
    #expect(page).to have_selector('#gtwy-type option[value="Spree::PaymentMethod::Bitpay"]'), "Not visible in drop down"
    expect(page).to have_selector('#bitpay_api_uri option[value="https://bitpay.com"]'), "No livenet dropdown"
    expect(page).to have_selector('#bitpay_api_uri option[value="https://test.bitpay.com"]'), "No testnet dropdown"
  end
end
