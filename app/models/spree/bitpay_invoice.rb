module Spree

  class BitpayInvoice < ActiveRecord::Base
    belongs_to :payment_method
    belongs_to :user
    has_many :payments, as: :source

    # DB fields: user_id, invoice_id

    attr_accessor :bogus  # bogus since we need to have a param that is passed to trigger Payment.build_source

    def actions
      # TODO: Refund action?	
      ["void"]
    end

    # Gets the JSON invoice from Bitpay
    def find_invoice
      payment_method.find_invoice(invoice_id)
    end

  end
end
