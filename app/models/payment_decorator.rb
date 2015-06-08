module Spree
  Payment.class_eval do
    def place_bitpay_order params
      if state == 'checkout'
        posDataJson = {paymentID: number, orderID: params[:orderID]}.to_json
        invoice = payment_method.create_invoice params.merge({posData: posDataJson, fullNotifications: "true"})
        source.bitpay_order_placed(invoice['id'])
        started_processing!
        invoice
      else
        invoice_id = source.invoice_id
        payment_method.get_invoice(id: invoice_id)
      end
    end
  end
end
