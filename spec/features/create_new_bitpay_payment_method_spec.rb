require 'spec_helper'
require 'features/step_helpers'

feature "Creating a new BitPay Payment Method", js: true, type: :feature do
  scenario "has a dropdown with 'test' and 'live' options" do
    login_admin
    create_new_payment_method "Bitcoin", "Spree::PaymentMethod::BitPay"
    expect(page).to have_selector('#bitpay_api_uri option[value="https://bitpay.com"]'), "No livenet dropdown"
    expect(page).to have_selector('#bitpay_api_uri option[value="https://test.bitpay.com"]'), "No testnet dropdown"
  end
  
  scenario 'the user is logged in to bitpay' do
    login_bitpay ENV['BPDEVSERVER'], ENV['BPUSER'], ENV['BPPASSWORD']
    login_admin
    old_url = current_url
    create_new_payment_method "Bitcoin", "Spree::PaymentMethod::BitPay"
    select("Development", from: "bitcoin_network")
    find_button("Authenticate with BitPay").click
    #click the approval button
    #do something else
  end

  scenario 'the user is logged out of bitpay' do
    login_admin
    create_new_payment_method "Bitcoin", "Spree::PaymentMethod::BitPay"
    old_url = current_url
    select("Development", from: "bitcoin_network")
    find_button("Authenticate with BitPay").click
    expect(current_url).to match(/#{ENV['BPDEVSERVER']}\/api-access-request\?pairingCode=[a-zA-Z0-9]{7}&redirect=#{old_url}/)
  end
  
  scenario "The form is exclusive to BitPay PaymentMethod" do
    login_admin
    create_new_payment_method "Not Bitcoin", "Spree::Gateway::Bogus"
    expect(page).not_to have_selector('#bitpay_api_uri option[value="https://bitpay.com"]'), "Livenet dropdown"
  end
  
end
