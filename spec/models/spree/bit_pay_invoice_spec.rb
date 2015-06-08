require 'spec_helper'

RSpec.describe Spree::BitPayInvoice, type: :model do
  subject { Spree::BitPayInvoice.create! }

  it 'should have a has_one association with payments' do
    expect(subject.association(:payments).class).to eq(ActiveRecord::Associations::HasManyAssociation)
  end
  it 'should have a belongs_to association with users' do
    expect(subject.association(:users).class).to eq(ActiveRecord::Associations::BelongsToAssociation)
  end
  it 'should have a belongs_to association with payment_method' do
    expect(subject.association(:payment_method).class).to eq(ActiveRecord::Associations::BelongsToAssociation)
  end
  it 'must respond to imported' do
    expect(subject.respond_to?(:imported)).to be true
  end
  it 'should return false to imported' do
    expect(subject.imported).to be false
  end

  it 'handles the "void" action' do
    expect(subject.actions).to eq(["void"])
  end

  context '.bitpay_order_placed' do
    it "responds to bitpay_order_placed" do
      expect(subject.respond_to?(:bitpay_order_placed)).to be true
    end

    it 'sets the invoice id' do
      newid = n_random_alpha_nums(6)
      subject.bitpay_order_placed(newid)
      expect(subject.invoice_id).to eq(newid)
    end
  end
end
