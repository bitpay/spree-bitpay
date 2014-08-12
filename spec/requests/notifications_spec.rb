require 'spec_helper'

describe "Notifications" do
	it "Handles 'paid' notification" do
		# Starting conditions:
		# Order: confirm
		# Payment: processing
		order = create(:order_with_line_items)
		payment_method = Spree::PaymentMethod.find_by(name: "Bitcoin") # There should be only one in the DB when tests run
		3.times {order.next!} # => address => delivery => payment
		create(:bitcoin_payment, amount: order.total, order: order, payment_method: payment_method)  # This actually associates the invoice with a random user but this doesn't seem problematic...
		order.next! # => confirm
		order.payments.first.started_processing! # => processing


		pending "Still need to do actual validation"


		#binding.pry
	end
	it "Handles 'confirmed' notification"
	it "Handles Overpayment"
	it "Handles Underpayment"
	it "Handles 'invalid' notification"
	it "Handles Late Payment"
	it "Handles non-existent orders"
	it "Handles non-existent payments"
	it "Handles false 'paid' notifications"
	it "Handles false 'confirmed' notifications"
end
