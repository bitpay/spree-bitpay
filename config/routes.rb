Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  post '/payment_method/bit_payments/authenticate'
  get '/spree_bitpay/invoice/new', :to => "bitpay#pay_now", :as => :bitpay_pay_now
  get '/spree_bitpay/invoice/view', :to => "bitpay#view_invoice", :as => :bitpay_view_invoice
  get '/spree_bitpay/payment_sent', :to => "bitpay#payment_sent", :as => :bitpay_payment_sent
  get '/spree_bitpay/cancel', :to => "bitpay#cancel", :as => :bitpay_cancel
  get '/spree_bitpay/refresh', :to => "bitpay#refresh", :as => :bitpay_refresh
  get '/spree_bitpay/check', :to => "bitpay#check_payment_state", :as => :bitpay_check
  post '/spree_bitpay/notification', :to => "bitpay#notification", :as => :bitpay_notification
end
