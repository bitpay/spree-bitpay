require 'bit_pay_rails'
require 'pry'

module Spree
  class PaymentMethod::BitPay < PaymentMethod
    has_one :bit_pay_client

    def authenticate_with_bitpay uri
      client_check = BitPayClient.find_by_bit_pay_id(self.id)
      client_check.destroy! unless client_check.nil?
      client = BitPayClient.create(api_uri: uri, bit_pay_id: self.id)
      client.save!
      client.get_pairing_code
    end

    def create_invoice params
      self.bit_pay_client.create_invoice(params)
    end

    def get_invoice params
      self.bit_pay_client.get_invoice(params)
    end
  end
  
end
