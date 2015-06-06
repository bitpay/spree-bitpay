require 'spec_helper'

RSpec.describe Spree::BitPayInvoice, type: :model do
  subject { Spree::BitPayInvoice.create! }

  it 'should have a has_one association with bit_pay_client' do
    expect(subject.association(:payments).class).to eq(ActiveRecord::Associations::HasManyAssociation)
  end

end
