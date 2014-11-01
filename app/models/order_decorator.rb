Spree::Order.class_eval do
  self.state_machine.before_transition :to => :confirm, :do => :validate_bitpay_payment

  def validate_bitpay_payment
    states = payments.map(&:state)
    payments.each do |payment|
      payment.failure if payment.state == 'processing'
    end if (states.include?('checkout') && states.include?('processing'))
  end

  def get_bitpay_payment
    checkout = payments.select{|payment| payment.state == 'checkout'}
    processing = payments.select{|payment| payment.state == 'processing'}
    return checkout.last if checkout.any?
    return processing.last if processing.any?
  end

  def find
    current_order || raise(ActiveRecord::RecordNotFound)
  end

  def find_by_session
    self.find(session[:order_id]) || raise(ActiveRecord::RecordNotFound)
  end

  def find_by_id
    self.find_by_number(order_id) || raise(ActiveRecord::RecordNotFound)
  end
end
