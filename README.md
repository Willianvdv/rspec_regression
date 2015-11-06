# RspecRegression
Did your change increased the number of queries?

## In your own rspec suite

Install this gem:
```
gem 'rspec_regression', github: 'willianvdv/rspec_regression'
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
