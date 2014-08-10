# Build extension test app and populate DB

export RAILS_ENV=test

rm -r spec/dummy
bundle exec rake test_app
cd spec/dummy
bundle exec rake db:seed AUTO_ACCEPT=1
bundle exec rake spree_sample:load

# Append stylesheets/js manually until fix applied
# https://github.com/spree/spree/issues/5157

gsed -i $'7i\\\n \*\= require spree\/frontend\n' vendor/assets/stylesheets/spree/frontend/all.css
gsed -i $'7i\\\n \*\= require spree\/backend\n' vendor/assets/stylesheets/spree/backend/all.css
gsed -i $'10i\\\n\/\/\= require spree\/frontend\n' vendor/assets/javascripts/spree/frontend/all.js
gsed -i $'10i\\\n\/\/\= require spree\/backend\n' vendor/assets/javascripts/spree/backend/all.js