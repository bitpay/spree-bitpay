class SpreeBitpayGenerator < Rails::Generators::Base
	def include_javascript
		append_file 'vendor/assets/javascripts/spree/frontend/all.js', "//= require spree/frontend/spree_bitpay\n"
		append_file 'vendor/assets/javascripts/spree/frontend/all.js', "//= require jquery.easyModal\n"
	end
    
    def include_stylesheets
        inject_into_file 'vendor/assets/stylesheets/spree/frontend/all.css', " *= require spree/frontend/spree_bitpay\n", :before => /\*\//, :verbose => true
        inject_into_file 'vendor/assets/stylesheets/spree/backend/all.css', " *= require spree/frontend/spree_bitpay\n", :before => /\*\//, :verbose => true
    end

    def add_migrations
    	run 'rake railties:install:migrations'
    end

    def run_migrations
        run 'bundle exec rake db:migrate'
    end
end