# Run Coverage report
require 'simplecov'
SimpleCov.start do
  add_filter 'spec/dummy'
  add_group 'Controllers', 'app/controllers'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Models', 'app/models'
  add_group 'Views', 'app/views'
  add_group 'Libraries', 'lib'
end

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)

require 'rspec/rails'
require 'capybara/rspec'
require 'webmock/rspec'
require 'database_cleaner'
require 'ffaker'
require 'pry'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

# Requires factories and other useful helpers defined in spree_core.
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/capybara_ext'
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/factories'
require 'spree/testing_support/url_helpers'

# Requires factories defined in lib/spree_bitpay/factories.rb
require 'spree_bitpay/factories'

# Require factories under spec/factories
Dir["#{File.dirname(__FILE__)}/factories/**"].each do |f|
  require File.expand_path(f)
end

# Use Poltergeist driver for compatibility with Travis CI, and tell it to ignore JS errors
require 'capybara/poltergeist'
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, :js_errors => false)
end
Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|

  # Deprecation Stuff
  config.expose_current_running_example_as :example
  config.infer_spec_type_from_file_location!

  config.include FactoryGirl::Syntax::Methods

  # == URL Helpers
  #
  # Allows access to Spree's routes in specs:
  #
  # visit spree.admin_path
  # current_path.should eql(spree.products_path)
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::Core::Engine.routes.url_helpers

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
  config.color = true

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
#  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # Capybara javascript drivers require transactional fixtures set to false, and we use DatabaseCleaner
  # to cleanup after each test instead.  Without transactional fixtures set to false the records created
  # to setup a test will be unavailable to the browser, which runs under a separate server instance.
  config.use_transactional_fixtures = false

   # Ensure Suite is set to use transactions for speed.
   config.before :suite do
     DatabaseCleaner.strategy = :transaction
     DatabaseCleaner.clean_with :truncation
   end

  config.before :each do
    # Disable Webmock restrictions for feature tests.
    if example.metadata[:type] == :feature
      WebMock.allow_net_connect!
    else
      WebMock.disable_net_connect!
    end

    #DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    #DatabaseCleaner.start
  end

   # # After each spec clean the database.
   # config.after :each do
   #   DatabaseCleaner.clean
   # end


  # In event of errors, open page
  config.after do
    if example.metadata[:type] == :feature and example.exception.present?
      save_and_open_screenshot
    end
  end

  config.fail_fast = true
  #config.fail_fast = ENV['FAIL_FAST'] || false
  #config.order = "random"
end

####
# Helper Methods
###

## Gets the fixture by name
#
def get_fixture(name)
  JSON.parse(File.read(File.expand_path("../fixtures/#{name}",  __FILE__)))
end