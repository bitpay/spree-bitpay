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
        pend
        void
      end
    end

    def process_bitpay_ipn
      invoice_id = source.invoice_id
      invoice = payment_method.get_invoice(id: invoice_id)
      process_invoice(invoice['status'])
      state.to_sym
    end

    private

    def process_invoice status
      case status
      when 'new'
        started_processing
      when 'paid'
        order.update!
        order.next
        pend!
       when 'complete', 'confirmed'
        order.update!
        order.next
        complete
      else
        failure
      end
    end
  end
end
