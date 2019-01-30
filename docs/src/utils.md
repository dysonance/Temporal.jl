# Package Options
There are two package options that can be adjusted to change the way that Temporal behaves.

## Range Delimiter
The `RANGE_DELIMITER` option specifies what value should separate the `String`s when indexing a `TS` object's rows using the `String` indexing syntax.

By default, `RANGE_DELIMITER` is set to `'/'`, and can be changed dynamically using the function `set_range_delimiter_option`.

```@repl
using Temporal, Dates;
t = Date("2017-01-01"):Day(1):Date("2017-12-31");
vals = rand(length(t), 4);
X = TS(vals, t)
X["2017-03-15/2017-06-15"]
set_range_delimiter_option("::")
X["2017-03-15::2017-06-15"]
```

## Name Sanitization
The `SANITIZE_NAMES` option is a boolean value indicating whether the column names (that is, the object's `fields` member), should be cleaned of whitespace and non-alphanumeric characters before constructing `TS` objects. This can make it easier to deal with names of columns more quickly and easily in some cases.

By default, `SANITIZE_NAMES` is set to `false`, so that generally speaking the raw user input data is used. This option can be changed with the `set_sanitize_names_option` function.

Notice in the sample below how the `Adj Close` column name becomes `AdjClose` after changing the setting to `true`.

```@repl
using Temporal, Dates;
A = tsread(Pkg.dir("Temporal", "data", "XOM.csv"))
set_sanitize_names_option(true)
B = tsread(Pkg.dir("Temporal", "data", "XOM.csv"))
```

## Rename columns

### Not in place

`rename` function return a `TS`.

```@repl
using Temporal
N = 252*3
K = 4
data = cumsum(randn(N,K), dims=1)
dates = today()-Day(N-1):Day(1):today()
ts = TS(data, dates, [:a, :b, :c, :d])
rename(ts, :a => :A, :d => :D)
rename(ts, Dict(:a => :A, :d => :D)...)
rename(Symbol ∘ uppercase ∘ string, ts)
rename(uppercase, ts, String)
```

### In place

`rename!` function modify name of columns in place and return `true` when a `TS` is renamed.

```julia
rename!(ts, :a => :A, :d => :D)
rename!(ts, Dict(:a => :A, :d => :D)...)
rename!(Symbol ∘ uppercase ∘ string, ts)
rename!(uppercase, ts, String)
```
