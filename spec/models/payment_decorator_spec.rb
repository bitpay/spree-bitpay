require 'spec_helper'
describe Spree::Payment do
  context '.process_bitpay_ipn' do
    before do
      @source_id = n_random_alpha_nums(10)
      @bpay = mock_model('Spree::PaymentMethod::BitPayment')
      @source = mock_model('Spree::BitPayInvoice')
      allow_any_instance_of(Spree::Payment).to receive(:payment_method).and_return(@bpay)
      allow_any_instance_of(Spree::Payment).to receive(:source).and_return(@source)
      allow(@source).to receive(:invoice_id).and_return(@source_id)
    end

    it 'responds to process_bitpay_ipn' do
      expect(subject.respond_to?(:process_bitpay_ipn)).to be true
    end

    it 'calls the payment method' do
      payment = create(:processing_bp_payment, order: create(:order))
      expect(@bpay).to receive(:get_invoice).with(id: @source_id).and_return(get_fixture('valid_new_invoice.json'))
      payment.process_bitpay_ipn
    end

    context 'invoice status is expired' do
      context 'the exception status is false' do
        it 'sets the payment state to invalid' do
          payment = create :processable_bp_payment, order: create(:order) 
          expect(@bpay).to receive(:get_invoice).with(id: @source_id).and_return(get_fixture('valid_expired_invoice.json'))
          payment.process_bitpay_ipn
          expect(payment.state).to eq 'invalid'
        end
      end
      context 'the exception status is not false' do
        it 'voids a voidable payment' do
          payment = create :voidable_bp_payment, order: create(:order)
          expect(@bpay).to receive(:get_invoice).with(id: @source_id).and_return(get_fixture('partial_paid_expired_invoice.json'))
          payment.process_bitpay_ipn
          expect(payment.state).to eq 'void'
        end
        it 'ignores a voidable payment' do
          payment = create :void_bp_payment, order: create(:order)
          expect(@bpay).to receive(:get_invoice).with(id: @source_id).and_return(get_fixture('partial_paid_expired_invoice.json'))
          payment.process_bitpay_ipn
          expect(payment.state).to eq 'void'
        end
      end
    end

    context 'invoice status is new' do
      it 'starts processing the order' do
        payment = create(:processable_bp_payment, order: create(:order))
        expect(@bpay).to receive(:get_invoice).with(id: @source_id).and_return(get_fixture("valid_new_invoice.json"))
        payment.process_bitpay_ipn
        expect(payment).to be_processing
      end
    end


#      when "paid" 
#
#        # Move payment to pending state and complete order 	
#
#        if payment.state = "processing" # This is the most common scenario
#          payment.pend!
#        else # In the case it was previously marked invalid due to invoice expiry
#          payment.state = "pending"
#          payment.save
#        end
#
#        payment.order.update!
#        payment.order.next
#        if (!payment.order.complete?)
#          raise "Can't transition order #{payment.order.number} to COMPLETE state"	
#        end
    context 'invoice status is paid' do
      context 'payment is in checkout state' do
        it 'pends the payment' do
          payment = create(:checkout_bp_payment, order: create(:order))
          expect(@bpay).to receive(:get_invoice).with(id: @source_id).and_return(get_fixture("valid_paid_invoice.json"))
          payment.process_bitpay_ipn
          expect(payment).to be_pending
        end
        it 'updates the payment order' do
          order = create(:order)
          payment = create(:checkout_bp_payment, order: order)
          expect(@bpay).to receive(:get_invoice).with(id: @source_id).and_return(get_fixture("valid_paid_invoice.json"))
          expect(order).to receive(:update!)
          expect(order).to receive(:next)
          payment.process_bitpay_ipn
        end
      end
      context 'payment is in invalid state' do
        it 'pends the payment' do
          payment = create(:invalid_bp_payment, order: create(:order))
          expect(@bpay).to receive(:get_invoice).with(id: @source_id).and_return(get_fixture("valid_paid_invoice.json"))
          payment.process_bitpay_ipn
          expect(payment).to be_pending
        end
        it 'updates the payment order' do
          order = create(:order)
          payment = create(:invalid_bp_payment, order: order)
          expect(@bpay).to receive(:get_invoice).with(id: @source_id).and_return(get_fixture("valid_paid_invoice.json"))
          expect(order).to receive(:update!)
          expect(order).to receive(:next)
          payment.process_bitpay_ipn
        end
      end
    end
    context 'invoice status is confirmed' do
      it 'completes the payment' do
        payment = create(:completable_bp_payment, order: create(:order))
        expect(@bpay).to receive(:get_invoice).with(id: @source_id).and_return(get_fixture("valid_confirmed_invoice.json"))
        payment.process_bitpay_ipn
        expect(payment).to be_completed
      end

      it 'updates the payment order' do
        payment = create(:checkout_bp_payment, order: create(:order))
        order = mock_model('Spree::Order')
        expect(@bpay).to receive(:get_invoice).with(id: @source_id).and_return(get_fixture("valid_confirmed_invoice.json"))
        expect(order).to receive(:update!)
        expect(order).to receive(:next)
        payment.stub(:order).and_return(order)
        payment.stub(:complete).and_return(true)
        payment.process_bitpay_ipn
      end
    end
    context 'invoice status is complete' do
      it 'completes the payment' do
        payment = create(:completable_bp_payment, order: create(:order))
        expect(@bpay).to receive(:get_invoice).with(id: @source_id).and_return(get_fixture("valid_complete_invoice.json"))
        payment.process_bitpay_ipn
        expect(payment).to be_completed
      end
    end
  end

  context '.cancel_bitpay_payment' do
    it 'responds to cancel_bitpay_payment' do
      expect(subject.respond_to?(:cancel_bitpay_payment)).to be true
    end
    it 'will cancel a processing bitpay payment' do
      payment = create(:processing_bp_payment, order: create(:order))
      payment.cancel_bitpay_payment
      expect(payment.state).to eq('void')
    end
    it 'will not cancel a processing not bitpay payment' do
      payment = create(:payment, state: 'processing')
      payment.cancel_bitpay_payment
      expect(payment.state).to eq('processing')
    end
  end

  context ".place_bitpay_order" do
      before do
        subject.stub(:number).and_return "THISVALUE"
        subject.stub(:started_processing!)
        allow(subject).to receive(:started_processing!)
        posDataJson = {paymentID: subject.number, orderID: "5678qwer"}.to_json
        @params = { price: "25.00",
                   currency: "AUS",
                   orderID: "5678qwer",
                   notificationURL: "https://this.url",
                   posData: posDataJson,
                   fullNotifications: true}
        @bpay = mock_model('Spree::PaymentMethod::BitPayment')
        @source = mock_model('Spree::BitPayInvoice')
        Spree::Payment.any_instance.stub(:payment_method).and_return(@bpay)
        Spree::Payment.any_instance.stub(:source).and_return(@source)
        allow(@source).to receive(:bitpay_order_placed)
        @invoice = {'id' => '12345', 'url' => 'https://that.url', 'price' => 24.00}
        @incoming_params = { notificationURL: "https://this.url", orderID: "5678qwer", price: "25.00", currency: "AUS" }
      end
    context "the payment state is 'checkout'" do
      it "responds to place_bitpay_order" do
        expect(subject.respond_to?(:place_bitpay_order)).to be true
      end

      it "generates the correct arguments for the invoice" do
        expect(@bpay).to receive(:create_invoice).with(@params).and_return(@invoice)
        subject.place_bitpay_order @incoming_params
      end

      it "tells the source to save the invoice" do
        allow(@bpay).to receive(:create_invoice).with(@params).and_return(@invoice)
        expect(@source).to receive(:bitpay_order_placed).with('12345')
        subject.place_bitpay_order @incoming_params
      end
      it 'returns the entire invoice' do 
        allow(@bpay).to receive(:create_invoice).with(@params).and_return(@invoice)
        expect(subject.place_bitpay_order( @incoming_params)).to eq(@invoice)
      end
    end
    context "the payment state is not 'checkout'" do
      before do
        subject.state = "confirm"
      end

      it "gets the invoice id from the source" do
        newid = n_random_alpha_nums(8)
        allow(@source).to receive(:invoice_id).and_return(newid)
        expect(@bpay).to receive(:get_invoice).with(id: newid)
        subject.place_bitpay_order @incoming_params
      end

      it "still returns the invoice" do
        newid = n_random_alpha_nums(8)
        allow(@source).to receive(:invoice_id).and_return(newid)
        expect(@bpay).to receive(:get_invoice).with(id: newid).and_return(@invoice)
        expect(subject.place_bitpay_order(@incoming_params)).to eq @invoice
      end
    end
  end
end
