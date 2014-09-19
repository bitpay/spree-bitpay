require 'spec_helper'

describe Spree::PaymentMethod::Bitpay do
  describe '#scan_the_server' do
    subject = FactoryGirl.create(:bitcoin_payment_method)
    it{ respond_to :scan_the_server }

    context 'when the invoice does not exist' do
      it "returns 'invoice not found'" do
        expect_any_instance_of(BitPay::Client).to receive(:get).and_return( { "error"=> { "type"=>"notFound", "message"=>"Invoice not found"} } )
        expect(subject.scan_the_server("5")).to eq("Invoice not found")
      end
    end

    context 'when the invoice has expired or paid' do
      it "returns 'expired' for expired invoices" do
        expect_any_instance_of(BitPay::Client).to receive(:get).and_return(get_fixture("valid_expired_invoice.json"))
        expect(subject.scan_the_server("5")).to eq("expired")
      end

      it "returns 'paid' for paid invoices" do
        expect_any_instance_of(BitPay::Client).to receive(:get).and_return(get_fixture("valid_paid_invoice.json"))
        expect(subject.scan_the_server("5")).to eq("paid")
      end
    end
  end
end
