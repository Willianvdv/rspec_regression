[![Circle
CI](https://circleci.com/gh/Willianvdv/rspec_regression.svg?style=svg)](https://circleci.com/gh/Willianvdv/rspec_regression)

# RspecRegression
Did your change increase the number of queries?

## In your own rspec suite

Install this gem:
```
gem 'rspec_regression', github: 'willianvdv/rspec_regression'
```

This gem contains executables. Bundler can set up binstubs for you:
```
bundle binstub rspec_regression
```

In your `spec_helper.rb`
```
config.before :suite do
  # This is a dirty solution until I find a better way to hot start specs (with
  # table information already fetched)
  ActiveRecord::Base.descendants.last.first
end

config.before :each do |example|
  RspecRegression::QueryRegressor.start_example example
end

config.after :each do |example|
  RspecRegression::QueryRegressor.end_example
end

config.after :suite do
  # This uploads the results to the regressor
  RspecRegression::QueryRegressor.store
end
```
When running rspec:
```
REGRESSOR_DOMAIN='http://localhost:4000' \
  REGRESSOR_API_TOKEN='uEeOTv0+gI8GKVtQ1M+Wxwh3TqNgkWJkYMpyLM8TFqBzO1+DJGHeqsKcUbd+dMmNYN7se6QhroQY9h/euYJLSg==' \
  REGRESSOR_PROJECT_ID='43b1312a-aca0-4a35-8f4e-d9d6b56b279c' \
  REGRESSOR_TAG="`git rev-parse HEAD`" \
  bx rspec spec/
```

(REGRESSOR_TAG is optional)
