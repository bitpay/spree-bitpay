# Notice

This is a Community-supported project.

If you are interested in becoming a maintainer of this project, please contact us at integrations@bitpay.com. Developers at BitPay will attempt to work along the new maintainers to ensure the project remains viable for the foreseeable future.

# BitPay plugin for Spree Commerce

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://raw.githubusercontent.com/bitpay/spree-bitpay/master/LICENSE.txt)
[![Travis](https://img.shields.io/travis/bitpay/spree-bitpay.svg?style=flat-square)](https://travis-ci.org/bitpay/spree-bitpay)
[![Gem](https://img.shields.io/gem/v/spree_bitpay.svg?style=flat-square)](https://rubygems.org/gems/spree_bitpay)
[![Code Climate](https://img.shields.io/codeclimate/github/bitpay/spree-bitpay.svg?style=flat-square)](https://codeclimate.com/github/bitpay/spree-bitpay)
[![Coveralls](https://img.shields.io/coveralls/bitpay/spree-bitpay.svg?style=flat-square)](https://coveralls.io/r/bitpay/spree-bitpay)

BitPay Payments connector for SpreeCommerce 3.0.x RoR storefront.  Accept bitcoin payments with ZERO fees.  Choose remittance in your local currency or take a percentage in BTC.  

Sign up for your account at https://bitpay.com.  
For development and testing against the bitcoin testnet, sign up at https://test.bitpay.com.

## Installation

## Last Version Tested: 2.2.1

### Environment

`spree-bitpay` relies on the `bitpay-rails` gem, which requires two environment variables to be set: `BPSECRET` and `BPSALT`. **You must set these environment variables**.

    $ export BPSECRET="YOURSECRETRIGHTHERE"
    $ export BPSALT="YOURSALTHERE"

### Intalling the gem

Add this line to your application's Gemfile:

    gem 'bitpay-rails', gem 'bitpay-rails', require: 'bit_pay_rails'
    gem 'spree_bitpay', :git => 'https://github.com/bitpay/spree-bitpay.git'

And then execute:

    $ bundle install

Then run

    $ rake bit_pay_rails_engine:install:migrations
    $ rake db:migrate

Failing to run the `bit_pay_rails` migrations before running the `spree_bitpay` migrations will cause the `spree_bitpay` migrations to fail, the `spree_bitpay` migrations have associations to the `bit_pay_rails` tables.

    $ rails generate spree_bitpay:install

Depending on your deployment configuration, you may need to precompile assets at this point in order to load the javascript files for the spree_bitpay gem.

The BitPay Spree connector receives RESTful confirmation callbacks at the `bitpay_notification_url` (typically `http://<host>/spree_bitpay/notification`).  **This route must be available to receive messages from https://bitpay.com for proper operation**.  This may require changes to your network configuration if your server is behind a firewall.  The connector has been implemented to verify any callbacks received at this route, to prevent fraudulent/spoof messages.

## Application Configuration

Once installed, configure the BitPayment payment method by logging into the Admin console by browsing to Configuration > Payment Methods.

Click the  "+ New Payment Method" button and choose the provider titled `Spree::PaymentMethod::BitPayment`.  Type a unique name that will be displayed to users when selecting a payment method. Click the `Create` button.

Once you have created the new payment method, it must be authenticated with BitPay. Select either `LiveNet` or `TestNet` from the dropdown and click the `Authenticate` button. This should redirect you to BitPay to authenticate the payment method.

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

   $ source spec/set_constants.sh https://test.bitpay.com <yourusername> <yourpassword>
   $ bundle exec rake

## Support

Questions?  Comments?  Suggestions?

Contact us at support@bitpay.com
