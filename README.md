# RspecRegression
Did your pull request increased the number of queries?

## Example
In `dummy/` you find a example application. Don't forget to bundle!

To record a base line pass `REGRESSION_STORE_RESULTS=1` as env variable when running `rspec`. For the
dummy application it looks like:

```
$ REGRESSION_STORE_RESULTS=1 AMOUNT_OF_PEOPLES_TO_CREATE=10 bundle exec rspec
```

To see a decreased query count, run the dummy application with less `AMOUNT_OF_PEOPLES_TO_CREATE`.
```
$ AMOUNT_OF_PEOPLES_TO_CREATE=9 bundle exec rspec
> -----------------
> Query regression
> -----------------
> Regression: Number of queries is decreased!
> person_with_variable_peoples_to_create_creates_some_more_peoples (./spec/models/person_spec.rb:13)
> - #27: - SAVEPOINT active_record_1
> - #28: - INSERT INTO "people" ("name", "created_at", "updated_at") VALUES (?, ?, ?)
> - #29: - RELEASE SAVEPOINT active_record_1
```

To see a increased query count, run the dummy application with more `AMOUNT_OF_PEOPLES_TO_CREATE`.

```
$ AMOUNT_OF_PEOPLES_TO_CREATE=11 bundle exec rspec
> -----------------
> Query regression
> -----------------
> Regression: Number of queries is increased!
> person_with_variable_peoples_to_create_creates_some_more_peoples (./spec/models/person_spec.rb:13)
> - #30: + SAVEPOINT active_record_1
> - #31: + INSERT INTO "people" ("name", "created_at", "updated_at") VALUES (?, ?, ?)
> - #32: + RELEASE SAVEPOINT active_record_1
```


## In your own rspec suite

Install this gem:
```
gem 'rspec_regression', github: 'willianvdv/rspec_regression'
```
In your `spec_helper.rb`

```
config.before :suite do
  # This is a temporary solution until I find a better way to hot start specs (with table information
  # already fetched)
  ActiveRecord::Base.descendants.last.first
end

config.before :each do |example|
  RspecRegression::QueryRegressor.start_example example
end

config.after :each do |example|
  RspecRegression::QueryRegressor.end_example
end

config.after :suite do
  RspecRegression::QueryRegressor.end
end
```
