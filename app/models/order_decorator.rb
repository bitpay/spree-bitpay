module Spree
  Order.class_eval do
    self.state_machine.before_transition :to => :confirm, :do => :validate_bitpay_payment

    def validate_bitpay_payment
      states = payments.map(&:state)
      payments.each do |payment|
        payment.failure if payment.state == 'processing'
      end if (states.include?('checkout') && states.include?('processing'))
    end

    def place_bitpay_order params
      new_params = {orderID: number, price: outstanding_balance, currency: currency}
      payment = get_bitpay_payment
      payment.place_bitpay_order(params.merge(new_params))
    end

    def get_bitpay_payment
      checkout = payments.select{|payment| payment.state == 'checkout'}
      processing = payments.select{|payment| payment.state == 'processing'}
      return checkout.last if checkout.any?
      return processing.last if processing.any?
    end

    def cancel_bitpay_payment
      payments.each(&:cancel_bitpay_payment)
    end

    def process_bitpay_ipn payment_id
      payment = payments.find_by_number(payment_id)
      payment.process_bitpay_ipn
    end

  end
end
