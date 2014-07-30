module Spree
  class BitpayController < StoreController
  	skip_before_filter :verify_authenticity_token, :only => [:notification]

	# Generates Bitpay Invoice and returns iframe view
	#
	def pay_now
		
		order = current_order || raise(ActiveRecord::RecordNotFound)

		return redirect_to root_url if order.state != "confirm"

		# Find the payment by searching for valid payments associated with the order
		# TODO: If there is more than 1, raise exception (can handle this corner case later)
		payment = order.payments.valid.first

		puts "Heres that payment: #{payment.inspect}"

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

		redirect_to (invoice["url"] + '&view=iframe')
	end

	# View Invoice with specific ID
	#
	def view_invoice
	
		invoice = BitpayInvoice.find(params[:source_id]).find_invoice
		redirect_to (invoice["url"] + '&view=iframe')
	end

	def cancel

		order = current_order || raise(ActiveRecord::RecordNotFound)

		# Find payment in processing state
		# TODO: is there a better way to look for this 
		order.payments.with_state("processing").each do |payment| 
			puts "in payment"
			if (payment.payment_method.is_a? Spree::PaymentMethod::Bitpay)
				puts "cancelling bp"
				payment.failure!				
			end
		end

		redirect_to edit_order_checkout_url(order, state: 'payment'), :notice => Spree.t(:checkout_cancelled)

	end

	# Fires on receipt of payment received window message
	#
	def payment_sent

		order = Spree::Order.find(session[:order_id]) || raise(ActiveRecord::RecordNotFound)

		session[:order_id] = nil # Reset cart
		 redirect_to spree.order_path(order), :notice => Spree.t(:order_processed_successfully)

	end

	# Handle IPN from Bitpay server
	#
	def notification

		# TODO:  Should this validate message origin somehow?  Compare to prefs from PaymentMethod?
		# Should not be fatal because we are re-validating all data provided

		posData = JSON.parse(params["posData"])

		order_id = posData["orderID"]
		payment_id = posData["paymentID"]

		# Get OFFICIAL Invoice from BitPay API
		# Fetching payment this way should prevent any false payment/order mismatch
		order = Spree::Order.find_by_number(order_id)
		payment = order.payments.find_by(identifier: payment_id) || raise(ActiveRecord::RecordNotFound)

		invoice = payment.source.find_invoice
		puts("Bitpay Invoice Content: " + invoice.to_json)
		process_invoice(invoice)

		render text: "", status: 200
	end

#######################################################################
###    Private Methods
#######################################################################

	private

	# # Returns the PaymentMethod object
	# def bitpay(pmid)
	# 	pm = Spree::PaymentMethod.find(pmid)
	# 	if !(pm.is_a? Spree::PaymentMethod::Bitpay)
	# 		raise "Not a BitPay payment type"
	# 	end
	# 	pm
	# end

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

      puts "Requesting Invoice with params: #{invoice_params}"
      invoice = payment.payment_method.get_bitpay_client.post 'invoice', invoice_params
      puts "Invoice Generated: #{invoice.inspect}"

      return invoice
    end

    # Process the invoice and adjust order state accordingly
    def process_invoice(invoice)
    	puts "Processing Bitpay invoice"

		# Extract posData
		posData = JSON.parse(invoice["posData"])

		# TODO: Handle nils here
		order_number = invoice["orderID"]
		invoice_id = invoice["id"]
		payment_id = posData["paymentID"]
		
		payment = Spree::Payment.find_by(identifier: payment_id) || raise(ActiveRecord::RecordNotFound)

		puts "Found Payment: #{payment.inspect}"

		case invoice["status"]
			when "new"
				payment.started_processing
			when "paid" 
				payment.pend
			when "confirmed", "complete"
				payment.complete
			when "expired"
				payment.failure
			when "invalid"
				payment.failure
			else
				puts "Unexpected status '#{invoice["status"]}'"
		end

		payment.order.update!

		if (payment.state == 'pending')
			payment.order.next

			if (!payment.order.complete?)
				puts "TODO: Error handling if order can't be transitioned"	
			end
		end

		puts "New Payment State: #{payment.state}"
		puts "New Order State: #{payment.order.state}"

    end

  end
end