PAYMENT_ID = "123PAYMENTID"
ORDER_ID   = "123ORDERID"
INVOICE_ID = "123BitPayInvoiceID"

FactoryGirl.define do
  factory :bit_payment, class: Spree::PaymentMethod::BitPayment do
    name 'BPAY'
  end
  factory :bitpay_invoice, class: Spree::BitPayInvoice do
  end

  factory :abstract_btc_payment, class: Spree::Payment do
    association :payment_method, factory: :bit_payment
    association :source, factory: :bitpay_invoice
    amount { order.total }
    response_code 'BTC'
    after(:create) do |payment|
      payment.save!
      payment.order.update!
    end

    factory :uncompletable_bp_payment do
      new_state = [:void, :invalid].sample
      state new_state
    end
    factory :unpayable_bp_payment do
      new_state = [:pending, :completed, :processing, :void].sample
      state new_state
    end
    factory :voidable_bp_payment do
      new_state = [:pending, :processing, :completed, :checkout].sample
      state new_state
    end    
    factory :failable_bp_payment do
      new_state = [:pending, :processing].sample
      state new_state
    end    
    factory :completable_bp_payment do
      new_state = [:checkout, :pending, :processing].sample
      state new_state
    end    
    factory :processable_bp_payment do
      new_state = [:checkout, :pending, :completed, :processing].sample
      state new_state
    end    
    factory :pendable_bp_payment do
      new_state = [:checkout, :processing].sample
      state new_state
    end    
    factory :uncheckout_bp_payment do
      new_state = [:pending, :completed, :processing, :invalid, :void].sample
      state new_state
    end    
    factory :void_bp_payment do
      state 'void'
    end    
    factory :checkout_bp_payment do
      state 'checkout'
    end    
    factory :pending_bp_payment do
      state 'pending'
    end    
    factory :invalid_bp_payment do
      state 'invalid'
    end    
    factory :processing_bp_payment do
      state 'processing'
    end
  end
end

def n_random_alpha_nums n
  alpha_nums = (("0".."9").to_a << ("A".."Z").to_a << ("a".."z").to_a).flatten
  (0..n).to_a.reduce(""){|a, b| a << alpha_nums.sample}
end
