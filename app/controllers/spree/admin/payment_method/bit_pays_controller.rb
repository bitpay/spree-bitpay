module Spree
  module Admin
    class PaymentMethod::BitPaysController < ApplicationController
      include Spree::Backend::Callbacks
 
      def index
        #network = params[:bitpay_api_uri]
      end
    
    end
  end
end
