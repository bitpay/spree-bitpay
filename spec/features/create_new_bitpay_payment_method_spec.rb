require 'spec_helper'
require 'features/step_helpers'

feature "Creating a new BitPay Payment Method", js: true, type: :feature do
  scenario "has a dropdown with 'test' and 'live' options" do
    login_admin
    create_new_payment_method "Bitcoin", "Spree::PaymentMethod::BitPay"
    expect(page).to have_selector('#bitpay_api_uri option[value="https://bitpay.com"]'), "No livenet dropdown"
    expect(page).to have_selector('#bitpay_api_uri option[value="https://test.bitpay.com"]'), "No testnet dropdown"
  end
  
  scenario "Choosing testnet redirects to testnet" do
    login_admin
    create_new_payment_method "Bitcoin", "Spree::PaymentMethod::BitPay"
    select("TestNet", from: "bitcoin_network")
    find_button("Authenticate with BitPay").click
    expect(current_host).to match("test.bitpay.com")
  end
  
  scenario "The form is exclusive to BitPay PaymentMethod" do
    login_admin
    create_new_payment_method "Not Bitcoin", "Spree::Gateway::Bogus"
    expect(page).not_to have_selector('#bitpay_api_uri option[value="https://bitpay.com"]'), "Livenet dropdown"
  end
  
end
