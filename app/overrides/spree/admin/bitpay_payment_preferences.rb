Deface::Override.new(virtual_path: "spree/admin/payment_methods/_form",
                     name: "bitpay_payment_preference",
                     replace: 'erb[loud]:contains("preference_fields")',
                     partial: "spree/admin/shared/bitpay_payment_preferences"
                    )
