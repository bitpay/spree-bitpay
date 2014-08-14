require 'spec_helper'

describe "Notifications" do
	it "rejects malformed notifications"
	it "Handles 'paid' notification" do

		payment = create(:processing_payment_with_confirming_order)
		order = payment.order

		# Validate Starting State
		expect(order.state).to eq("confirm")
		expect(order.payments.first.state).to eq("processing")

		# Send 'paid' notification callback 
		callback_body = get_fixture("valid_paid_callback.json")
		invoice = get_fixture("valid_paid_invoice.json")

		stub_request(:get, "https://bitpay.com/api/invoice/123BitPayInvoiceID").
         to_return(:status => 200, :body => invoice.to_json)
		
		post bitpay_notification_path, callback_body

		expect(order.reload.state).to eq("complete")
		expect(payment.reload.state).to eq("pending") 

	end
	it "Handles 'confirmed' notification"
	it "Handles Overpayment"
	it "Handles Underpayments that are later accepted"
	it "Handles 'invalid' notification"
	it "Handles Late Payment"
	it "Handles non-existent orders"
	it "Handles non-existent payments"
	it "Handles false 'paid' notifications"
	it "Handles false 'confirmed' notifications"
	it "Handles 'paid' notifications for Payments in 'invalid' state"
end
