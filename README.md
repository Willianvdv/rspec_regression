# RspecRegression

wip

## Usage

```
config.after :suite do
  RspecRegression::QueryRegressor.results
end

config.before :each do |example|
  RspecRegression::QueryRegressor.start_example example
end

config.after :each do |example|
  RspecRegression::QueryRegressor.end_example
end
```

## Diffs

Without created_at and updated_at timestamps
```
diff <(cat /tmp/latest.sqls | sed "s/\"updated_at\" = '.*'/\"updated_at = <UPDATE_AT_TIMESTAMP>/g" | sed "s/\"updated_at\" = '.*'/\"created_at = <CREATED_AT_TIMESTAMP>/g") <(cat /tmp/current.sqls | sed "s/\"updated_at\" = '.*'/\"updated_at = <UPDATE_AT_TIMESTAMP>/g" | sed "s/\"updated_at\" = '.*'/\"created_at = <CREATED_AT_TIMESTAMP>/g")
```
