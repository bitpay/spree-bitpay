Spree::Core::Engine.routes.draw do
  get '/spree_bitpay/invoice/new', :to => "bitpay#pay_now", :as => :bitpay_pay_now
  get '/spree_bitpay/invoice/view', :to => "bitpay#view_invoice", :as => :bitpay_view_invoice
  get '/spree_bitpay/payment_sent', :to => "bitpay#payment_sent", :as => :bitpay_payment_sent
  post '/spree_bitpay/notification', :to => "bitpay#notification", :as => :bitpay_notification
end
