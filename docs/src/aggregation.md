# Aggregation

## Sampling

### Weekdays

```@docs
mondays
tuesdays
wednesdays
thursdays
fridays
saturdays
sundays
```

### Interval Boundaries

#### Weekly
```@docs
bow
eow
```

#### Monthly
```@docs
bom
eom
```

#### Quarterly
```@docs
boq
eoq
```

#### Yearly
```@docs
boy
eoy
```

## Collapsing

```@docs
collapse
```

```@repl
using Temporal, Statistics, Dates
X = TS(randn(100, 4))
collapse(X, eom, fun=mean)
last_month = string(X.index[end])[1:7]
mean(X[last_month])
```

## Summarizing

```@docs
apply
```

```@repl
using Temporal, Statistics
X = TS(randn(100, 4))
apply(X, 1, fun=sum)
apply(X, 2, fun=sum)
```
