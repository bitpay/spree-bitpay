module Spree
  class PaymentMethod::Bitpay < PaymentMethod
    preference :api_key, :string
    preference :api_endpoint, :string, :default => "https://bitpay.com/api"

    def auto_capture?
      true
    end

    def payment_source_class
      Spree::BitpayInvoice
    end

    def payment_profiles_supported?
      # Set true to force confirmation step.
      true
    end

    def source_required?
      false
    end

#######################################################################
###    Instance Utility Methods
#######################################################################

    def find_invoice(id)
      get_bitpay_client.get ('invoice/' + id)
    end

    def get_bitpay_client
      BitPay::Client.new(preferred_api_key, {api_uri: preferred_api_endpoint})
    end

# TODO:  These are minimally implemented to clear blocks on the Spree side...

    def void (action, order_id, id)
      ActiveMerchant::Billing::Response.new(true, 'Bogus Gateway: Forced success')
    end

  end
end