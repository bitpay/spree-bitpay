# Build extension test app and populate DB

rm -r spec/dummy
bundle exec rake test_app
cd spec/dummy
bundle exec rake db:seed AUTO_ACCEPT=1
bundle exec rake spree_sample:load
