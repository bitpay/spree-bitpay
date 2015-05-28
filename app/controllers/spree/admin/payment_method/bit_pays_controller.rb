module Spree
  module Admin
    class PaymentMethod::BitPaysController < ApplicationController
      include Spree::Backend::Callbacks
 
      def authenticate
        payment_method = Spree::PaymentMethod::BitPay.find(params[:payment_method_id])
        pairing_code = payment_method.authenticate_with_bitpay params[:bitcoin_network]
        url = "#{params[:bitcoin_network]}/api-access-request?pairingCode=#{pairing_code}&redirect=#{params[:redirect_url]}"
        redirect_to url
      end
    
    end
  end
end
