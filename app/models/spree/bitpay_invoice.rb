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

    def find_valid_payments(order)

      # Find the payment by searching for valid payments associated with the order
      # VOID payments are considered valid, so need to exclude those too
      payment = order.get_bitpay_payment

      logger.debug "Found payment: #{payment.inspect}"

      case payment.state
      when "checkout"
        # New checkout - create an invoice, and attach its id to the payment.source
        invoice = new_invoice(order, payment)
        payment.source.invoice_id = invoice['id']
        payment.source.save!
        payment.started_processing!
      else
        # An invoice was already created - find it
        invoice = payment.source.find_invoice
      end
    end

    def return_iframe_view
      @invoice_iframe_url = "#{invoice['url']}&view=iframe"
      render json: @invoice_iframe_url
    end

    #TODO: move to model
    def invalidate_processing_payments
      # Find and invalidate Bitpay payment in processing state
      @order.payments.with_state("processing").each do |payment|
        if (payment.payment_method.is_a? Spree::PaymentMethod::Bitpay)
          payment.state = "invalid"  # Have to set this explicitly since Spree state machine prevents it
          payment.save!
        end
      end
    end

  end
end
