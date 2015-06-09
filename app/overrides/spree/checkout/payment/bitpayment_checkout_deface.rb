Deface::Override.new(virtual_path: "spree/payments/_payment",
                     name: "bitpay_checkout",
                     insert_after: 'erb[loud]:contains("payment_method")',
                     partial: 'spree/checkout/confirm/bitpayment_confirm'
                    )
