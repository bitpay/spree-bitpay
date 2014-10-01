## Factories for setting up Spree BitPay inflight orders/payments 
# 
#

# Easily recognizable dummy values

PAYMENT_ID = "123PAYMENTID"
ORDER_ID   = "123ORDERID"
INVOICE_ID = "123BitPayInvoiceID"


FactoryGirl.define do
  ## Creates a payment in 'processing' state with associated order in 'confirm' state
  #
  factory :abstract_btc_payment, class: Spree::Payment do
    association :payment_method, factory: :bitcoin_payment_method
    association :source, factory: :bitcoin_invoice
    amount { order.total }
    response_code 'BTC'
    after(:create) do |payment|
      payment.identifier = PAYMENT_ID
      payment.save!
      payment.order.update!
    end

    factory :processing_payment_with_confirming_order do
      state 'processing'
      association :order, factory: :order_with_line_items, state: "confirm", number: ORDER_ID
    end

    factory :pending_payment_with_complete_order do
      state 'pending'
      association :order, factory: :order_with_line_items, state: "complete", number: ORDER_ID
    end

    factory :invalid_payment_with_confirming_order do
      state 'invalid'
      association :order, factory: :order_with_line_items, state: "confirm", number: ORDER_ID
    end    

    factory :invalid_payment do
      state 'invalid'
    end    

  end

  factory :bitcoin_payment_method, class: Spree::PaymentMethod::Bitpay do
    name 'Bitcoin Auto'
    environment 'test'
  end

  factory :bitcoin_invoice, class: Spree::BitpayInvoice do
    association :user 
    invoice_id INVOICE_ID
    association :payment_method, factory: :bitcoin_payment_method
  end

end
