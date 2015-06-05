require 'spec_helper'

describe Spree::PaymentMethod::BitPayment do
  subject { Spree::PaymentMethod::BitPayment.create! name: 'aba' }

  it 'should have a has_one association with bit_pay_client' do
    expect(subject.association(:bit_pay_client).class).to eq(ActiveRecord::Associations::HasOneAssociation)
  end

  it 'should have a source' do
    expect(subject.payment_source_class).to be(Spree::BitPayInvoice)
  end
  
  context 'payment_profiles' do
    it 'should support payment profiles' do
      expect(subject.payment_profiles_supported?).to be true
    end

    it 'should create a nil profile' do
      expect(subject.create_profile("anything")).to be_nil
    end
  end
  
  context '.authenticate_with_bitpay' do
    it 'should create a new BitPayClient with itself when attempting to pair' do
      bpclient = mock_model('BitPayClient')
      random_string = ('0'..'z').to_a.sample((rand(10) + 10)).join
      allow(bpclient).to receive(:save!)
      allow(bpclient).to receive(:get_pairing_code).with(no_args)
      expect(BitPayClient).to receive(:create).with(api_uri: random_string, bit_payment_id: subject.id).and_return(bpclient)
      subject.authenticate_with_bitpay(random_string)
    end

    it 'should associate the newly created BitPayClient with itself' do
      subject.authenticate_with_bitpay 'whatever'
      expect(subject.bit_pay_client).not_to be_nil
    end

    it 'should retrieve a pairing code' do
      bpclient = mock_model('BitPayClient')
      random_string = ('0'..'z').to_a.sample((rand(10) + 10)).join
      random_pairing_code = ('0'..'z').to_a.sample(7).join
      allow(bpclient).to receive(:save!)
      allow(bpclient).to receive(:get_pairing_code).with(no_args).and_return(random_pairing_code)
      allow(BitPayClient).to receive(:create).with(api_uri: random_string, bit_payment_id: subject.id).and_return(bpclient)
      expect(subject.authenticate_with_bitpay(random_string)).to eq(random_pairing_code)
    end

    it 'deletes pre-existing clients associated with payment method' do
      2.times { subject.authenticate_with_bitpay('Bad token') }
      expect(BitPayClient.count).to eq(1)
    end
  end

  context '.create_invoice' do
    it 'should create an invoice' do
      params = { price: 8.88, currency: 'USD', user: { name: 'Bob Dole' } }
      bpclient = mock_model('BitPayClient')
      allow(subject).to receive(:bit_pay_client).and_return(bpclient)
      expect(bpclient).to receive(:create_invoice).with(params)
      subject.create_invoice(params)
    end
  end

  context '.get_invoice' do
    it 'should retrieve and invoice by id' do
      params = { param1: 1, param2: 'this' }
      bpclient = mock_model('BitPayClient')
      allow(subject).to receive(:bit_pay_client).and_return(bpclient)
      expect(bpclient).to receive(:get_invoice).with(params)
      subject.get_invoice(params)
    end
  end

  context '.paired?' do
    before do
      @bpclient = mock_model('BitPayClient')
      allow(subject).to receive(:bit_pay_client).and_return(@bpclient)
    end

    it 'should return false if the client is not authorized' do
      allow(@bpclient).to receive(:get_tokens).and_return(nil)
      expect(subject.paired?).to eq(false)
    end

    it 'should return false if the client has no tokens' do
      allow(@bpclient).to receive(:get_tokens).and_return([])
      expect(subject.paired?).to eq(false)
    end

    it 'should return false if the client has no merchant token' do
      allow(@bpclient).to receive(:get_tokens).and_return('pos' => '5aDx4WYPZ8MYJh95APqStERrKcGPucUyC3E412b4dV8m')
      expect(subject.paired?).to eq(false)
    end

    it 'should return true if the client has a merchant token' do
      allow(@bpclient).to receive(:get_tokens).and_return([{ 'pos' => '5aDx4WYPZ8MYJh95APqStERrKcGPucUyC3E412b4dV8m' }, { 'merchant' => '5aDx4WYPZ8MYJh95APqStERrKcGPucUyC3E412b4dV8m' }])
      expect(subject.paired?).to eq(true)
    end
  end
end
