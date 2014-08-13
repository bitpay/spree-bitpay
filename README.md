# BitPay plugin for Spree Commerce
[![Build Status](https://travis-ci.org/heisler3030/spree_bitpay.svg)](https://travis-ci.org/heisler3030/spree_bitpay)

BitPay Payments connector for SpreeCommerce RoR storefront.  Accept bitcoin payments with ZERO fees.  Choose remittance in your local currency or take a percentage in BTC.  

Sign up for your account at https://bitpay.com.  
For development and testing against the bitcoin testnet, sign up at https://test.bitpay.com.

## Installation

Add this line to your application's Gemfile:

    gem 'spree_bitpay'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spree_bitpay

Then run 

    $ rails generate spree_bitpay:install

The BitPay Spree connector receives RESTful confirmation callbacks at the `bitpay_notification_url` (typically http://<host>/spree_bitpay/notification).  This route must be available to receive messages from https://bitpay.com for proper operation.  The connector has been implemented to verify any callbacks received at this route, to prevent malicious transactions.

## Application Configuration

Once installed, configure the BitPay payment method by logging into the Admin console by browsing to Configuration > Payment Methods.

Click the  "+ New Payment Method" button and choose the provider titled `Spree::PaymentMethod::Bitpay`.  Type a unique name that will be displayed to users when selecting a payment method.

Once you click the "Create" button there will be two additional parameters that should be completed.  Input your API Key from your Bitpay dashboard, and specify an API endpoint.  For production you should use `https://bitpay.com/api`, while for testing purposes you can use `https://test.bitpay.com/api` which will monitor for payments on the bitcoin testnet.  Note that you must have a separate account and API Key for test.bitpay.com.

## User Experience

Once installed and configured, users will be able to select Bitcoin on the Payment step of the Checkout process.

![BTC Invoice](http://heisler3030.github.io/PaymentType.png)

After confirming their order details, users are presented with a modal Bitcoin invoice for payment.  

![BTC Invoice](http://heisler3030.github.io/BTCInvoice.png)

When the payment is detected on the Bitcoin network, the modal will update and allow them to continue to the confirmation page.  

![BTC Invoice Confirmed](http://heisler3030.github.io/BTCInvoiceConfirmed.png)

## Backend Processing

When a user selects Bitcoin as a payment method, a new `Payment` is created, in `checkout` state, along with a new `BitpayInvoice`, which links to the invoiceID created at BitPay.com.

In the event Bitcoin checkout is abandoned or the invoice expires, the `Payment` is marked `invalid`.

When a payment is detected on the Bitcoin network, the `Payment` is marked `pending`, and the `Order` is set `complete`.  The user is presented with a confirmation screen.

When the Bitcoin transaction is fully confirmed according to your BitPay [transaction speed settings](https://bitpay.com/order-settings), a callback is delivered to the `bitpay_notification_url`, and verified with the BitPay server.  At this stage the payment will be marked `complete`, and the fullfillment can proceed.

At any point, the details and current status of a BitPay payment can be viewed by clicking on the payment in the order detail screen 

![BTC Invoice Confirmed](http://heisler3030.github.io/InvoiceDetails.png)


## Plugin Testing

The BitPay Spree connector uses RSpec, Capybara, and Poltergeist to perform integration testing.  To set up and run the tests, you must install PhantomJS, as described [here](https://github.com/teampoltergeist/poltergeist#installing-phantomjs).  Then execute the following steps:

    bundle install
    ./testapp.sh
    rake

## Support

Questions?  Comments?  Suggestions?

Contact us at support@bitpay.com
