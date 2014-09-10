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

    # Set true to force confirmation step.
    # http://guides.spreecommerce.com/developer/checkout.html#confirmation
    #
    def payment_profiles_supported?
      true
    end

    ## Dummy method to satisfy test factories
    #
    def create_profile(payment)
      nil
    end

    def source_required?
      false
    end

#######################################################################
###    Instance Utility Methods
#######################################################################

    ## Retreive Invoice by ID from BitPay
    #
    def find_invoice(id)
      id ? ( get_bitpay_client.get ('invoice/' + id) ) : nil
    end

    ## Interface with BitPay 
    #
    def get_bitpay_client
      BitPay::Client.new(preferred_api_key, {api_uri: preferred_api_endpoint})
    end

    ## This is a stub method which simply returns true to allow the cancel on the Spree side
    #
    def void (action, order_id, id)
      ActiveMerchant::Billing::Response.new(true, 'Bogus Gateway: Forced success')
    end

  end
end
