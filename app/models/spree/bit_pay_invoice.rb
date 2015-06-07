module Spree
  class BitPayInvoice < ActiveRecord::Base
    belongs_to :users
    belongs_to :payment_method
    has_many :payments, as: :source

    attr_accessor :bogus  # bogus since we need to have a param that is passed to trigger Payment.build_source

    def actions
      # TODO: Refund action?
      ["void"]
    end

    def imported
      false
    end

    # Gets the JSON invoice from Bitpay
    def find_invoice
      payment_method.find_invoice(invoice_id)
    end

  end
end
