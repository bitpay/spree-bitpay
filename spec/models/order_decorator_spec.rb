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
      expect(payment).to receive(:place_bitpay_order).with(notification_url: "https://this.url", orderID: subject.number, price: subject.outstanding_balance, currency: subject.currency)
      subject.place_bitpay_order(notification_url: "https://this.url")
    end

  end
  context "#get_bitpay_payment" do
    before do
      FactoryGirl.create(:invalid_payment, order: subject)
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
end
