# Indexing

## Overview
One of the chief aims of the `Temporal.jl` package is to simplify the process of extracting a desired subset from a time series dataset. To that end, there are quite a few different methods by which one can index specific rows/columns of a `TS` object.

One goal has been to keep as much of the relevant indexing operations from the base `Array` type as possible to maintain consistency. However, there are certain indexing idioms that are specifically more familiar and meaningful to tabular time series data, particularly when prototyping in the REPL.

In other words, if you want to use standard `Array` indexing syntax, it should work as you would expect, but you should also be able to essentially say, "give me all the observations from the year _2017_ in the _price_ column."

## Numerical Indexing

### Integer

```@repl
using Temporal
X = TS(cumsum(randn(252, 4), dims=1)) + 100.0
X[1]
X[1, :]
X[:, 1]
X[1, 1]
```

### Boolean

```@repl
using Temporal
X = TS(cumsum(randn(252, 4), dims=1)) + 100.0
X[trues(size(X,1)), :]
X[rand(Bool, size(X,1)), 1]
X[rand(Bool, size(X,1)), [true, false, false, false]]
```

### Arrays & Ranges

```@repl
using Temporal
X = TS(cumsum(randn(252, 4), dims=1)) + 100.0
X[1:10, :]
X[end-100:end, 2:3]
X[end, 2:end]
```

## Symbol Indexing

You can also index specific columns you want using the `fields` member of the `TS` object, so that columns can be fetched by name rather than by numerical index.

```@repl
using Temporal
X = TS(cumsum(randn(252, 4), dims=1)) + 100.0
X[:, :A]
X[:, [:B, :D]]
```

## String Indexing

One of the more powerful features of Temporal's indexing functionality is that you can index rows of a `TS` object using `String`s formatted in such a way as to express specific periods of time in a natural idiomatic way. (If you have used the `xts` package in R this functionality will feel very familiar.)

```@repl
using Dates, Temporal
t = Date(2016,1,1):Day(1):Date(2017,12,31)
X = TS(cumsum(randn(length(t), 4), dims=1), t) + 100.0
X["2017-07-01"]  # single day
X["2016"]  # whole year
X["2016-09-15/"]  # everything after a specific day
X["/2017-07-01"]  # everything up through a specific month
X["2016-09-15/2017-07-01"]  # mix & match
```
