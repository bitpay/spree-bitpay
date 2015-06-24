module Spree
  class BitpayController < StoreController
    skip_before_filter :verify_authenticity_token, :only => [:notification]

    # Generates Bitpay Invoice and returns iframe view
    #
    def pay_now
      order = current_order || raise(ActiveRecord::RecordNotFound)
      session[:order_number] = current_order.number
      invoice = order.place_bitpay_order notificationURL: bitpay_notification_url
      @invoice_iframe_url = "#{invoice['url']}&view=iframe"
      render json: @invoice_iframe_url
    end

    # View Invoice with specific ID
    #
    def view_invoice
      invoice = BitPayInvoice.find(params[:source_id]).find_invoice
      redirect_to (invoice["url"] + '&view=iframe')
    end

    def check_payment_state
      invoice = BitPayInvoice.where(invoice_id: params[:invoice_id]).first
      pm = PaymentMethod.find(invoice.payment_method_id)
      status = pm.scan_the_server(invoice.invoice_id)
      render json: status
    end

    def cancel

      order = current_order || raise(ActiveRecord::RecordNotFound)
      order.cancel_bitpay_payment
      redirect_to edit_order_url(order, state: 'payment'), :notice => Spree.t(:order_canceled)

    end

    # Fires on receipt of payment received window message
    #
    def payment_sent
      order_number = session[:order_number]
      session[:order_number] = nil
      order = Spree::Order.find_by_number(order_number) || raise(ActiveRecord::RecordNotFound)
      redirect_to spree.order_path(order), :notice => Spree.t(:order_processed_successfully)
    end

    ## Handle IPN from Bitpay server
    # Receives incoming IPN message and retrieves official BitPay invoice for processing
    #
    def notification

      begin
        posData = JSON.parse(params["posData"])

        order_id = posData["orderID"]
        payment_id = posData["paymentID"]

        order = Spree::Order.find_by_number(order_id) || raise(ActiveRecord::RecordNotFound)
        begin
          order.process_bitpay_ipn payment_id
          head :ok
        rescue => exception
          logger.debug exception
          head :uprocessable_entity
        end
      rescue => error
        logger.error "Spree_Bitpay:  Unprocessable notification received from #{request.remote_ip}: #{params.inspect}"
        head :unprocessable_entity	
      end
    end

    # Reprocess Invoice and update order status 
    #
    def refresh
      payment = Spree::Payment.find(params[:payment])  # Retrieve payment by ID
      old_state = payment.state
      payment.process_bitpay_ipn
      new_state = payment.reload.state
      notice = (new_state == old_state) ? Spree.t(:bitpay_payment_not_updated) : (Spree.t(:bitpay_payment_updated) + new_state.titlecase)
      redirect_to (request.referrer || root_path), notice: notice
    end
  end
end
