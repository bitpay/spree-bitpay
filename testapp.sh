# Build extension test app and populate DB

export RAILS_ENV=test

rm -r spec/dummy
bundle exec rake test_app
