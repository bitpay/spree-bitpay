FactoryGirl.define do
  factory :bitcoin_payment, class: Spree::Payment do
    amount 45.75
    association(:payment_method, factory: :bitcoin_payment_method)
    association(:source, factory: :bitcoin_invoice)
    order
    state 'checkout'
    response_code 'BTC'
  end

  factory :bitcoin_payment_method, class: Spree::PaymentMethod::Bitpay do
    name 'Bitcoin Auto'
    environment 'test'
  end

  factory :bitcoin_invoice, class: Spree::BitpayInvoice do
    association(:user)
    invoice_id ""
    association(:payment_method, factory: :bitcoin_payment_method)
  end

end