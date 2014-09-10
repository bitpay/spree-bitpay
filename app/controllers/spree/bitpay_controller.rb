module Spree
  class BitpayController < StoreController
    skip_before_filter :verify_authenticity_token, :only => [:notification]

    # Generates Bitpay Invoice and returns iframe view
    #
    def pay_now

      order = current_order || raise(ActiveRecord::RecordNotFound)

      return redirect_to root_url if order.state != "confirm"

      # Find the payment by searching for valid payments associated with the order
      # VOID payments are considered valid, so need to exclude those too
      payments = order.payments.where.not(state: %w(failed invalid void))

      if payments.count > 1  # If there are other completed payments use the one in checkout state
        payment = payments.where(state: "checkout").first
      else 
        payment = payments.first
      end

      logger.debug "Found payment: #{payment.inspect}"

      case payment.state
      when "checkout"
        # New checkout - create an invoice, and attach its id to the payment.source
        invoice = new_invoice(order, payment)
        payment.source.invoice_id = invoice['id']
        payment.source.save!
        payment.started_processing!
      else
        # An invoice was already created - find it
        invoice = payment.source.find_invoice
      end

      @invoice_iframe_url = "#{invoice['url']}&view=iframe"
      render json: @invoice_iframe_url
    end

    # View Invoice with specific ID
    #
    def view_invoice

      invoice = BitpayInvoice.find(params[:source_id]).find_invoice
      redirect_to (invoice["url"] + '&view=iframe')
    end

    def cancel

      order = current_order || raise(ActiveRecord::RecordNotFound)

      # Find and invalidate Bitpay payment in processing state
      order.payments.with_state("processing").each do |payment| 
        if (payment.payment_method.is_a? Spree::PaymentMethod::Bitpay)
          payment.state = "invalid"  # Have to set this explicitly since Spree state machine prevents it
          payment.save!
        end
      end

      redirect_to edit_order_url(order, state: 'payment'), :notice => Spree.t(:checkout_cancelled)

    end

    # Fires on receipt of payment received window message
    #
    def payment_sent

      order = Spree::Order.find(session[:order_id]) || raise(ActiveRecord::RecordNotFound)

      session[:order_id] = nil # Reset cart
      redirect_to spree.order_path(order), :notice => Spree.t(:order_processed_successfully)

    end

    ## Handle IPN from Bitpay server
    # Receives incoming IPN message and retrieves official BitPay invoice for processing
    #
    def notification

      posData = JSON.parse(params["posData"])

      order_id = posData["orderID"]
      payment_id = posData["paymentID"]

      # Get OFFICIAL Invoice from BitPay API
      # Fetching payment this way should prevent any false payment/order mismatch
      order = Spree::Order.find_by_number(order_id) || raise(ActiveRecord::RecordNotFound)
      payment = order.payments.find_by(identifier: payment_id) || raise(ActiveRecord::RecordNotFound)
      invoice = payment.source.find_invoice

      if invoice
        logger.debug("Bitpay Invoice Content: " + invoice.to_json)
        process_invoice(invoice)
        head :ok
      else
        raise "Spree_Bitpay:  No invoice found for notification for #{payment.identifier} from #{request.remote_ip}"
      end

    rescue
      logger.error "Spree_Bitpay:  Unprocessable notification received from #{request.remote_ip}: #{params.inspect}"
      head :unprocessable_entity	
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

    # Call Bitpay API and return new JSON invoice object
    #
    def new_invoice(order, payment)

      # Have to encode this into a string for proper handling by API
      posDataJson = {paymentID: payment.identifier, orderID: order.number}.to_json

      invoice_params = {
        price: order.outstanding_balance,
        currency: order.currency,
        orderID: order.number,
        notificationURL: bitpay_notification_url,
        posData: posDataJson,
        fullNotifications: "true"
      }

      logger.debug "Requesting Invoice with params: #{invoice_params}"
      invoice = payment.payment_method.get_bitpay_client.post 'invoice', invoice_params
      logger.debug "Invoice Generated: #{invoice.inspect}"

      return invoice
    end

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
