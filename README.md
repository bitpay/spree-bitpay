# spree_bitpay 
[![Build Status](https://travis-ci.org/heisler3030/spree_bitpay.svg)](https://travis-ci.org/heisler3030/spree_bitpay)

BitPay Payments connector for SpreeCommerce RoR storefront. 

## Installation

Add this line to your application's Gemfile:

    gem 'spree_bitpay'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spree_bitpay

Then run 

    $ rails generate spree_bitpay:install

## Usage

Once installed, spree_bitpay can be configured as a new payment method by logging into the Admin console and browsing to Configuration > Payment Methods.

Click the  "+ New Payment Method" button and choose the provider titled "Spree::PaymentMethod::Bitpay".  Type a unique name that will be displayed to users when selecting a payment method.

Once you click the "Create" button there will be two additional parameters that should be completed.  Input your API Key from your Bitpay dashboard, and specify an API endpoint.  For production you should use "https://bitpay.com/api", while for testing purposes you can use "https://test.bitpay.com/api" which will monitor for payments on the bitcoin testnet.  Note that you must have a separate account and API Key for test.bitpay.com.
