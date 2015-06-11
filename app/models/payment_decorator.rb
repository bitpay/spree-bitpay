module Spree
  Payment.class_eval do
    def place_bitpay_order params
      if state == 'checkout'
        posDataJson = {paymentID: number, orderID: params[:orderID]}.to_json
        invoice = payment_method.create_invoice params.merge({posData: posDataJson, fullNotifications: true})
        source.bitpay_order_placed(invoice['id'])
        invoice
      else
        invoice_id = source.invoice_id
        payment_method.get_invoice(id: invoice_id)
      end
    end

    def cancel_bitpay_payment
      if state == 'processing' && payment_method.class == Spree::PaymentMethod::BitPayment
        void
      end
    end

    def process_bitpay_ipn
      invoice_id = source.invoice_id
      invoice = payment_method.get_invoice(id: invoice_id)
      process_invoice(invoice['status'], invoice['exceptionStatus'])
    end

    private

    def process_invoice (status, exception_status = nil)
      case status
      when 'new'
        started_processing
      when 'paid'
        if state == 'checkout'
          update_and_state :pend!
        elsif state == 'invalid'
          update_attribute(:state, 'checkout')
          update_and_state :pend!
        end
        order_is_complete!
       when 'complete', 'confirmed'
         update_and_state :complete
         order_is_complete!
       when 'expired'
         if exception_status == false
           self.update_attribute(:state, 'invalid')
         else
           void
         end
      else
        failure
      end
    end

    def update_and_state state
      order.update!
      order.next
      send state
    end

    def order_is_complete!
      raise "Unable to complete. Order: #{order.number} receive unexpected BitPay ipn for payment #{number}" unless order.complete?
    end
  end
end
