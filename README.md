# RspecRegression

## Diffs

Without created_at and updated_at timestamps
```
diff <(cat /tmp/latest.sqls | sed "s/\"updated_at\" = '.*'/\"updated_at = <UPDATE_AT_TIMESTAMP>/g" | sed "s/\"updated_at\" = '.*'/\"created_at = <CREATED_AT_TIMESTAMP>/g") <(cat /tmp/current.sqls | sed "s/\"updated_at\" = '.*'/\"updated_at = <UPDATE_AT_TIMESTAMP>/g" | sed "s/\"updated_at\" = '.*'/\"created_at = <CREATED_AT_TIMESTAMP>/g")
```
