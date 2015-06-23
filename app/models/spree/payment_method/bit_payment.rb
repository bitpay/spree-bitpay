require 'bit_pay_rails'

module Spree
  class PaymentMethod::BitPayment < PaymentMethod
    has_one :bit_pay_client

    def authenticate_with_bitpay uri
      client_check = BitPayClient.find_by_bit_payment_id(self.id)
      client_check.destroy! unless client_check.nil?
      client = BitPayClient.create(api_uri: uri, bit_payment_id: self.id)
      client.save!
      client.get_pairing_code
    end

    def create_invoice params
      self.bit_pay_client.create_invoice(params)
    end

    def get_invoice params
      self.bit_pay_client.get_invoice(params)
    end

    def paired? 
      response = self.bit_pay_client.get_tokens
      return false if response.nil? || response.empty?
      check_tokens(response)
    end

    def api_uri
      self.bit_pay_client.api_uri
    end

    def payment_source_class
      Spree::BitPayInvoice
    end

    def payment_profiles_supported?
      true
    end

    def create_profile payment
      nil
    end

    def source_required?
      false
    end
    private
    
    def check_tokens response
      return response.reduce(false){|acc, resp| acc || check_token(resp) } if response.class == Array
      check_token response
    end

    def check_token response
      response.keys[0] == "merchant"
    end
  end
  
end
