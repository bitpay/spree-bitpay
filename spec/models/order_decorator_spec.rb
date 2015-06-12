require 'spec_helper'

describe Spree::Order do
  let!(:processing_payment) { FactoryGirl.create(:abstract_btc_payment, order: subject, state: 'processing') }
  let(:bpay) { create :bit_payment }
  let(:source) { create :bitpay_invoice }
  subject { create :order } 
  context ".place_bitpay_order" do
    it "responds to place_bitpay_order" do
      expect(subject.respond_to?(:place_bitpay_order)).to be true
    end
    it "calls its bitpay payment to create an invoice" do
      payment = mock_model(Spree::Payment)
      Spree::Order.any_instance.stub(:get_bitpay_payment).and_return(payment)
      subject.stub(:price).and_return("THISISAPRICE")
      expect(payment).to receive(:place_bitpay_order).with(notificationURL: "https://this.url", orderID: subject.number, price: subject.outstanding_balance, currency: subject.currency)
      subject.place_bitpay_order(notificationURL: "https://this.url")
    end

  end
  context "#get_bitpay_payment" do
    before do
      FactoryGirl.create(:invalid_bp_payment, order: subject)
    end

    it "returns a single processing payment if there is only one processing payment" do
      subject.update!
      expect(subject.get_bitpay_payment).to eq processing_payment
    end

    it 'returns a checkout payment if one exists' do
      FactoryGirl.create(:abstract_btc_payment, order: subject, state: 'processing')
      checkout_payment = FactoryGirl.create(:abstract_btc_payment, order: subject, state: 'checkout')
      subject.update!
      expect(subject.get_bitpay_payment).to eq checkout_payment
    end
  end

  context ".cancel_bitpay_payment" do
    it 'responds to cancel_bitpay_payment' do
      expect(subject.respond_to?(:cancel_bitpay_payment)).to be true
    end

    it 'calls cancel_bitpay_payment on all payments' do
      expect_any_instance_of(Spree::Payment).to receive(:cancel_bitpay_payment)
      subject.cancel_bitpay_payment
    end
  end

  context ".process_bitpay_ipn" do
    it 'responds to "process_bitpay_ipn"' do
      expect(subject.respond_to?(:process_bitpay_ipn)).to be true
    end

    it "passes the processing to the payment that was called" do
      order = create(:order_with_line_items)
      pay_id = n_random_alpha_nums(8)
      payment = create(:processing_bp_payment, order: order)
      payment.update_attribute(:number, pay_id)
      expect_any_instance_of(Spree::Payment).to receive(:process_bitpay_ipn)
      order.process_bitpay_ipn pay_id
    end
  end

  context "#validate_bitpay_payment" do
    it "returns the paymets unchanged if there is only one processing payment, and no checkout payments" do
      FactoryGirl.create(:invalid_bp_payment, order: subject)
      subject.update!
      subject.validate_bitpay_payment
      expect(subject.payments.map(&:state)).to eq ['processing', 'invalid']
    end

    it "returns a checkout payment if there is a checkout payment and a processing payment" do
      checkout_payment = FactoryGirl.create(:abstract_btc_payment, order: subject, state: 'checkout')
      subject.update!
      subject.validate_bitpay_payment
      expect(subject.payments.map(&:state)).to eq ['failed', 'checkout']
    end
  end

end

