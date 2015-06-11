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
      redirect_to edit_order_url(order, state: 'payment'), :notice => Spree.t(:checkout_cancelled)

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
      invoice = payment.source.find_invoice  # Get associated invoice
      process_invoice(invoice)	# Re-process invoice
      new_state = payment.reload.state
      notice = (new_state == old_state) ? Spree.t(:bitpay_payment_not_updated) : (Spree.t(:bitpay_payment_updated) + new_state.titlecase)
      redirect_to (request.referrer || root_path), notice: notice
    end

    #######################################################################
    ###    Private Methods
    #######################################################################

    private

    # Process the invoice and adjust order state accordingly
    # Accepts BitPay JSON invoice object
    #
    def process_invoice(invoice)
      logger.debug "Processing Bitpay invoice"

      # Extract posData
      posData = JSON.parse(invoice["posData"])

      payment_id = posData["paymentID"]
      status = invoice["status"]
      exception_status = invoice["exceptionStatus"]

      payment = Spree::Payment.find_by(identifier: payment_id) || raise(ActiveRecord::RecordNotFound)

      logger.debug "Found Payment: #{payment.inspect}"

      # Advance Payment state according to Spree flow
      # http://guides.spreecommerce.com/user/payment_states.html

      case status
      when "new"

        payment.started_processing

      when "paid" 

        # Move payment to pending state and complete order 	

        if payment.state = "processing" # This is the most common scenario
          payment.pend!
        else # In the case it was previously marked invalid due to invoice expiry
          payment.state = "pending"
          payment.save
        end

        payment.order.update!
        payment.order.next
        if (!payment.order.complete?)
          raise "Can't transition order #{payment.order.number} to COMPLETE state"	
        end

      when "confirmed", "complete"

        # Move payment to 'complete' state

        case payment.state
        when "pending" # This is the most common scenario
          payment.complete
        when "completed" 
          # Do nothing
        else 
          # Something unusual happened - maybe a notification was missed, or 
          # Make sure the order is completed
          if !payment.order.complete? 
            payment.state = "pending"
            payment.save
            payment.order.next
            if (!payment.order.complete?)
              raise "Can't transition order #{payment.order.number} to COMPLETE state"	
            end
          end
          payment.state = "completed"  # Can't use Spree payment.complete! method since we are transitioning from weird states
          payment.save
        end

      when "expired"

        if (exception_status == false)  # This is an abandoned invoice
          payment.state = "invalid"  # Have to set this explicitly since Spree state machine prevents it
          payment.save!
        else 
          # Don't think this will be anything other than paidPartial exceptionStatus
          unless payment.state == 'void'
            payment.void!
          end
        end

      when "invalid"

        unless payment.state == 'failed' 
          payment.failure!  # Will be flagged risky automatically
        end

      else

        raise "Unexpected status received from BitPay: '#{invoice["status"]}' for '#{invoice["url"]}"

      end

      logger.debug "New Payment State for #{payment.identifier}: #{payment.state}"
      logger.debug "New Order State for #{payment.order.number}: #{payment.order.state}"

    end

  end
end
