# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spree_bitpay/version'

Gem::Specification.new do |s|
  s.platform      = Gem::Platform::RUBY
  s.name          = "spree_bitpay"
  s.version       = SpreeBitpay::VERSION
  s.authors       = 'BitPay, Inc.'
  s.email         = 'info@bitpay.com'
  s.summary       = 'BitPay bitcoin payments plugin'
  s.homepage      = 'https://bitpay.com'
  s.version       = '0.1.0'
  s.required_ruby_version = '>= 1.9.3'

  s.files         = `git ls-files -z`.split("\x0")
  s.test_files    = Dir["spec/**/*"]
  s.require_paths = ["lib"]

  s.add_dependency 'spree', '~> 2.2.0'
  s.add_dependency 'spree_auth_devise'
  s.add_dependency 'bitpay-client', '>=0.1.3'
  
  s.add_development_dependency 'capybara', '~> 2.1'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.4'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'sass-rails', '~> 4.0.2'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'pry'

end
