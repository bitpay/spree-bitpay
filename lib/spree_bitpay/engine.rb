require 'bitpay'

module SpreeBitpay
  class Engine < Rails::Engine

    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_bitpay'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer "spree.bitpay.payment_methods", :after => "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::PaymentMethod::Bitpay
    end
  end
end

# Add permitted attribute so we can pass some source params and trigger Payment.build_source for BitpayInvoices
Spree::PermittedAttributes.source_attributes.push(:bogus)