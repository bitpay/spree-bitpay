Deface::Override.new(virtual_path: "spree/admin/payment_methods/edit",
                     name: "bitpay_payment_preference",
                     insert_before: 'erb[loud]:contains("form_for @payment_method")',
                     partial: "spree/admin/shared/bitpay_payment_preferences"
                    )
