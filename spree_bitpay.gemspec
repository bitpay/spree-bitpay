# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spree_bitpay/version'

Gem::Specification.new do |spec|
  spec.name          = "spree_bitpay"
  spec.version       = SpreeBitpay::VERSION
  spec.authors       = 'Bitpay, Inc.'
  spec.email         = 'info@bitpay.com'
  spec.summary       = 'Bitpay bitcoin payments plugin'
  spec.homepage      = 'https://bitpay.com'
  spec.version       = '0.1.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'spree_core', '~> 2.2.0'
  spec.add_dependency 'bitpay-client'
  
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
