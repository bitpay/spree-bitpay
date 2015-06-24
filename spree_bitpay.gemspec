# encoding: UTF-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spree_bitpay/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_bitpay'
  s.version     = SpreeBitpay::VERSION
  s.summary     = 'Accept bitcoin with BitPay'
  s.description = 'BitPay connector for the Spree shopping cart'
  s.required_ruby_version = '>= 2.0.0'

   s.author    = 'Bitpay Integrations'
   s.email     = 'integrations@bitpay.com'
  # s.homepage  = 'http://www.spreecommerce.com'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 3.0.1'
  s.add_dependency 'bitpay-rails', '~> 2.0'


  s.add_development_dependency 'capybara', '~> 2.4'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.5'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 3.1'
  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'sass-rails', '~> 5.0.0.beta1'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'coveralls'
end
