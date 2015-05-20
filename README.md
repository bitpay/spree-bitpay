# BitPay plugin for Spree Commerce
[![Build Status](https://travis-ci.org/bitpay/spree-bitpay.svg?branch=master)](https://travis-ci.org/bitpay/spree_bitpay)

BitPay Payments connector for SpreeCommerce 2.2.x RoR storefront.  Accept bitcoin payments with ZERO fees.  Choose remittance in your local currency or take a percentage in BTC.  

Sign up for your account at https://bitpay.com.  
For development and testing against the bitcoin testnet, sign up at https://test.bitpay.com.

## Installation

Add this line to your application's Gemfile:

    gem 'spree_bitpay', :git => 'https://github.com/bitpay/spree-bitpay.git'

And then execute:

    $ bundle install

Then run 

    $ rails generate spree_bitpay:install

The BitPay Spree connector receives RESTful confirmation callbacks at the `bitpay_notification_url` (typically `http://<host>/spree_bitpay/notification`).  **This route must be available to receive messages from https://bitpay.com for proper operation**.  This may require changes to your network configuration if your server is behind a firewall.  The connector has been implemented to verify any callbacks received at this route, to prevent fraudulent/spoof messages.

## Application Configuration

Once installed, configure the BitPay payment method by logging into the Admin console by browsing to Configuration > Payment Methods.

Click the  "+ New Payment Method" button and choose the provider titled `Spree::PaymentMethod::Bitpay`.  Type a unique name that will be displayed to users when selecting a payment method.

Once you click the "Create" button there will be two additional parameters that should be completed.  Input your API Key from your Bitpay dashboard, and specify an API endpoint.  For production you should use `https://bitpay.com/api`, while for testing purposes you can use `https://test.bitpay.com/api` which will monitor for payments on the bitcoin testnet.  Note that you must have a separate account and API Key for test.bitpay.com.

## User Experience

Once installed and configured, users will be able to select Bitcoin on the Payment step of the Checkout process.

![Payment Type](https://cloud.githubusercontent.com/assets/4770544/6882661/470ce9d0-d54a-11e4-83ac-e29d8bb04310.png)

After confirming their order details, users are presented with a modal Bitcoin invoice for payment.  

![BTC Invoice](https://cloud.githubusercontent.com/assets/4770544/6882659/46b90216-d54a-11e4-8a5a-94d5ff5392f6.png)

When the payment is detected on the Bitcoin network, the modal will update and allow them to continue to the confirmation page.  

![BTC Invoice Confirmed](https://cloud.githubusercontent.com/assets/4770544/6882658/46b8698c-d54a-11e4-9ec0-5fc83a7a97cf.png)

## Backend Processing

When a user selects Bitcoin as a payment method, a new `Payment` is created, in `checkout` state, along with a new `BitpayInvoice`, which links to the invoiceID created at BitPay.com.

In the event Bitcoin checkout is abandoned or the invoice expires, the `Payment` is marked `invalid`.

When a payment is detected on the Bitcoin network, the `Payment` is marked `pending`, and the `Order` is set `complete`.  The user is presented with a confirmation screen.

When the Bitcoin transaction is fully confirmed according to your BitPay [transaction speed settings](https://bitpay.com/order-settings), a callback is delivered to the `bitpay_notification_url`, and verified with the BitPay server.  At this stage the payment will be marked `complete`, and the fullfillment can proceed.

At any point, the details and current status of a BitPay payment can be viewed by clicking on the payment in the order detail screen 

![Invoice Details](https://cloud.githubusercontent.com/assets/4770544/6882660/470a03f0-d54a-11e4-8e2f-0cf82fd6091a.png)


## Plugin Testing

The BitPay Spree connector uses RSpec, Capybara, and Poltergeist to perform integration testing.  To set up and run the tests, you must install PhantomJS, as described [here](https://github.com/teampoltergeist/poltergeist#installing-phantomjs).  Then execute the following steps:

    export BITPAYKEY=<your test.bitpay.com api key here>
    bundle install
    ./testapp.sh
    rake

## Support

Questions?  Comments?  Suggestions?

Contact us at support@bitpay.com
