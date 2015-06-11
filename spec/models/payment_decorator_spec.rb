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

    context 'invoice status is new' do
      it 'starts processing the order' do
        payment = create(:processable_bp_payment, order: create(:order))
        expect(@bpay).to receive(:get_invoice).with(id: @source_id).and_return(get_fixture("valid_new_invoice.json"))
        payment.process_bitpay_ipn
        expect(payment).to be_processing
      end
    end

    context 'invoice status is paid' do
      it 'pends the payment' do
        payment = create(:processing_bp_payment, order: create(:order))
        expect(@bpay).to receive(:get_invoice).with(id: @source_id).and_return(get_fixture("valid_paid_invoice.json"))
        payment.process_bitpay_ipn
        expect(payment).to be_pending
      end
    end
    context 'invoice status is confirmed' do
      it 'completes the payment' do
        payment = create(:completable_bp_payment, order: create(:order))
        expect(@bpay).to receive(:get_invoice).with(id: @source_id).and_return(get_fixture("valid_confirmed_invoice.json"))
        payment.process_bitpay_ipn
        expect(payment).to be_completed
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
    context 'invoice status is expired' do
      it 'fails the payment' do
        payment = create(:failable_bp_payment, order: create(:order))
        expect(@bpay).to receive(:get_invoice).with(id: @source_id).and_return(get_fixture("valid_expired_invoice.json"))
        state = payment.process_bitpay_ipn
        expect(payment).to be_failed
        expect(state).to be :failed 
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
