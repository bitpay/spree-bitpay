require 'spec_helper'
require 'features/step_helpers'

feature "Creating a new BitPay Payment Method", js: true, type: :feature do
  scenario "has a dropdown with 'test' and 'live' options" do
    login_admin
    create_new_payment_method "Bitcoin", "Spree::PaymentMethod::BitPayment"
    expect(page).to have_selector('#bitpay_api_uri option[value="https://bitpay.com"]'), "No livenet dropdown"
    expect(page).to have_selector('#bitpay_api_uri option[value="https://test.bitpay.com"]'), "No testnet dropdown"
  end
  
  scenario 'the user is logged out of bitpay' do
    login_admin
    create_new_payment_method "Bitcoin", "Spree::PaymentMethod::BitPayment"
    old_url = current_url
    select("Development", from: "bitcoin_network")
    find_button("Connect To BitPay").click()
    expect(current_url).to match(/#{ENV['BPDEVSERVER']}\/api-access-request\?pairingCode=[a-zA-Z0-9]{7}&redirect=#{old_url}/)
  end
  
  scenario "The form is exclusive to BitPay PaymentMethod" do
    login_admin
    create_new_payment_method "Not Bitcoin", "Spree::Gateway::Bogus"
    expect(page).not_to have_selector('#bitpay_api_uri option[value="https://bitpay.com"]'), "Livenet dropdown"
  end
  
  scenario "The payment method is not authenticated" do
    login_admin
    create_new_payment_method "Bitcoind", "Spree::PaymentMethod::BitPayment"
    expect(find("#bitpay_pairing_status")).to have_content('Not Authenticated')
  end

  scenario "The payment method is authenticated" do
    @bpclient = mock_model('BitPayClient')
    allow_any_instance_of(Spree::PaymentMethod::BitPayment).to receive(:bit_pay_client).and_return(@bpclient)
    allow(@bpclient).to receive(:get_tokens).and_return([{ 'pos' => '5aDx4WYPZ8MYJh95APqStERrKcGPucUyC3E412b4dV8m' }, { 'merchant' => '5aDx4WYPZ8MYJh95APqStERrKcGPucUyC3E412b4dV8m' }])
    allow(@bpclient).to receive(:api_uri).and_return("https://this.old.man")
    login_admin
    create_new_payment_method "We are paired", "Spree::PaymentMethod::BitPayment"
    expect(find("#bitpay_pairing_status")).to have_content("Authenticated with https://this.old.man")
  end

end
