require 'spec_helper'

describe Spree::Order do
  let!(:processing_payment) { FactoryGirl.create(:abstract_btc_payment, order: subject, state: 'processing') }

  describe "#validate_bitpay_payment" do
    it "returns the paymets unchanged if there is only one processing payment, and no checkout payments" do
      FactoryGirl.create(:invalid_payment, order: subject)
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

  describe "#get_bitpay_payment" do
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
  

