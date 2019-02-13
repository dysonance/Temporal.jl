
```@setup overview
using Temporal, Dates, Indicators, Plots, Pkg, Random
```

# Temporal
This package provides a flexible & efficient time series class, `TS`, for the [Julia](http://julialang.org/) programming language. While still early in development, the overarching goal is for the class to be able to slice & dice data with the rapid prototyping speed of [R](https://www.r-project.org/)'s [`xts`](https://github.com/joshuaulrich/xts) and [Python](https://www.python.org/)'s [`pandas`](http://pandas.pydata.org/) packages, while retaining the performance one expects from Julia.

## Installation
 Temporal can be easily installed using Julia's built-in package manager.

```julia
using Pkg
Pkg.add("Temporal")
using Temporal
```

## Introduction

### The `TS` Type

#### Member Variables
`TS` objects store three member variables to facilitate data manipulation and analysis.
- `values`: an `Array` of the values of the time series data
- `index`: a `Vector` whose elements are either of type `Date` or `DateTime` indexing the values of the time series
- `fields`: a `Vector` whose elements are of type `Symbol` representing the column names of the time series data

#### Constructors
The `TS` object type can be created in a number of ways. One thing to note is that when constructing the `TS` object, passing only the `Array` of `values` will automatically create the `index` and the `fields` members. When not passed explicitly, the `index` defaults to a series of dates that ends with today's date, and begins `N-1` days before (where `N` is the number of rows of the `values`). The `fields` (or column names) are automatically set in a similar fashion as Excel when not given explicitly (A, B, C, ..., X, Y, Z, AA, AB, ...).

```@repl overview
using Temporal, Dates
N, K = 100, 4;
Random.seed!(1);
values = rand(N, K);
TS(values)
index = today()-Day(N-1):Day(1):today();
TS(values, index)
fields = [:A, :B, :C, :D];
X = TS(values, index, fields)
```

Equivalently, one can construct a TS object using the standard `rand` construction approach.

```@repl overview
Random.seed!(1);
Y = rand(TS, (N,K))
X == Y
```

### Operations

The standard operations that apply to `Array` objects will generally also work for `TS` objects. (If there is an operation that does *not* have a method defined for the `TS` type that you feel is missing, please don't hesitate to submit an [issue](https://github.com/dysonance/Temporal.jl/issues) and we will get it added ASAP.)

```@repl overview
cumsum(X)
cumprod(1 + diff(log(Y)))
X + Y
abs.(sin.(X))
```

# Usage

## Data Input/Output
There are currently several options for how to get time series data into the Julia environment as `Temporal.TS` objects.
- Data Vendor Downloads
    - [Quandl](https://www.quandl.com/)
    - [Yahoo! Finance](https://finance.yahoo.com/)
    - [Google Finance](https://finance.google.com)
- Local Flat Files (CSV, TSV, etc.)

### Quandl Data Downloads

```@repl overview
corn = quandl("CHRIS/CME_C1", from="2010-06-09", thru=string(Dates.today()), freq='w')  # weekly corn price history
corn = dropnan(corn)  # remove rows with any NaN
```

### Yahoo! Finance Downloads

```@repl overview
snapchat_prices = yahoo("SNAP", from="2017-03-03")  # historical prices for Snapchat since its IPO date
exxon_dividends = yahoo("XOM", event="div", from="2000-01-01", thru="2009-12-31")  # all dividend payments Exxon disbursed during the 2000's
```

### Flat File I/O

```@repl overview
filepath = "tmp.csv"
tswrite(corn, filepath)
tsread(filepath) == corn
```

## Subsetting/Indexing

Easily one of the more important parts of handling time series data is the ability to retrieve from that time series specific portions of the data that you want. To this end, `TS` objects provide a fairly flexible indexing interface to make it easier to slice & dice data in the ways commonly desired, while maintaining an emphasis on speed and performance wherever possible.

As an example use case, let us analyze the price history of front-month crude oil futures.

```@repl overview
crude = quandl("CHRIS/CME_CL1")  # download crude oil prices from Quandl
crude = dropnan(crude)  # remove the missing values from the downloaded data
```

### Column Indexing

The `fields` member of the `Temporal.TS` object (wherein the column names are stored) are represented using Julia's builtin `Symbol` datatype.

```@repl overview
crude[:Settle]
crude[[:Settle,:Volume]]
crude[1:100, :Volume]
```

A series of financial extractor convenience functions are also made available for commonly used tasks involving the selection of specific fields from historical financial market data.

```@repl overview
vo(crude)  # volume
op(crude)  # open
hi(crude)  # high
lo(crude)  # low
cl(crude)  # close (note: will take fields named :Close, :AdjClose, :Settle, and :Last)
```

```@example overview
ohlc(crude)
ohlcv(crude)
hl(crude)
hlc(crude)
hl2(crude)   # average of high and low
hlc3(crude)  # average of high, low, and close
ohlc4(crude) # average of open, high, low, and close
```

### Row Indexing

Rows of `TS` objects can be indexed in much the same way as Julia's standard `Array` objects. Since time is the key differentiating characteristic of a time series dataset, however, indexing only one dimension with an integer (or array of integers) defaults to indexing along the time (row) dimension.

```@repl overview
crude[1]  # get the first row
crude[end,:]  # get the last row
crude[end-100:end, 1:4]
```

Additionally, rows can be selected/indexed using `Date` or `DateTime` objects (whichever type corresponds to the element type of the object's `index` member).

```@repl overview
final_date = crude.index[end]
crude[final_date]
crude[collect(today()-Year(1):Day(1):today())]
```

Finally, Temporal provides a querying interface that allows one to use a standardized string format structure to specify ranges of dates. Inspired by R's xts package, one of the most useful utilities for prototyping in the REPL is the ease with which one can subset out dates simply by passing easily readable character strings. `Temporal` implements this same logic for `TS` objects.

On a tangential note, it's interesting to observe that while this indexing logic is implemented in low-level `C` code in other packages, this logic has been implemented in pure julia, making it far easier to read, interpret, understand, debug, and/or adapt to one's own purposes.

```@repl overview
crude["2016"]  # retrieve all rows from the year 2016
crude["2015", 6]  # retrive the sixth column from 2015
crude["/2017", 1:4]  # retrieve first four columns for all rows through 2017
crude["2015/", end-2:end]  # retrieve last three columns for the year 2015 and on
crude["2014/2015", :Settle]  # retrieve settle prices for the years 2014 and 2015
```

## Combining/Joining

```@repl overview
gasoline = quandl("CHRIS/CME_RB1")
gasoline_settles = cl(gasoline)
gasoline_settles.fields = [:Gasoline]

crude_settles = cl(crude)
crude_settles.fields[1] = :Crude;

# full outer join
A = ojoin(crude_settles, gasoline_settles)

# hcat -- same as full outer join
A = [crude_settles gasoline_settles]
```

```@example overview
# can join to arrays of same size
A = [A randn(size(A,1))]
```

```@example overview
# can join to single numbers as well
A = [A 0]
```

```@example overview
# inner join -- keep points in time where both objects have observations
ijoin(crude_settles, gasoline_settles)
```

```@example overview
# left join
ljoin(crude_settles, gasoline_settles)
```

```@example overview
# right join
rjoin(crude_settles, gasoline_settles)
```

```@example overview
# vertical concatenation also implemented!
fracker_era = [crude["/2013"]; crude["2016/"]]
```

## Collapsing/Aggregating

```@example overview
# Get the last values observed at the end of each month
eom(crude)
```

```@example overview
# (NOTE: the `eom` function returns a Boolean Vector when passed a Vector of TimeTypes)
[crude.index eom(crude.index)]
```

```@example overview
# monthly averages for all columns
collapse(crude, eom(crude.index), fun=mean)
```

```@example overview
# Get the total yearly trading volume of crude oil
collapse(crude[:Volume], eoy(crude.index), fun=sum)
```

# Visualization

Visualization capabilities are made available by the plotting API's made available by the impressively thorough and all-encompassing [Plots.jl](https://github.com/JuliaPlots/Plots.jl) package. Temporal uses the [RecipesBase](https://github.com/JuliaPlots/RecipesBase.jl) package to enable use of the whole suite of `Plots.jl` functionality while still permitting Temporal to precompile. The package [Indicators](https://github.com/dysonance/Indicators.jl) package is used to compute the moving averages seen below.

```@example overview
# download historical prices for crude oil futures and subset
X = quandl("CHRIS/CME_CL1")
subset = "2012/"
x = cl(X)[subset]
x.fields[1] = :CrudeFutures

# merge with some technical indicators
D = [x sma(x,n=200) ema(x,n=50)]

# visualize the multivariate time series object
plotlyjs()
ℓ = @layout [ a{0.7h}; b{0.3h} ]
plot(D, c=[:black :orange :cyan], w=[4 2 2], layout=ℓ, subplot=1)
plot!(wma(x,n=25), c=:red, w=2, subplot=1)
bar!(X["2012/",:Volume], c=:grey, alpha=0.5, layout=ℓ, subplot=2)
```

![alt text](https://raw.githubusercontent.com/dysonance/Temporal.jl/master/examples/visualization_example1.png)

# Miscellany

## Acknowledgements
This package is inspired mostly by R's [xts](https://github.com/joshuaulrich/xts) package and Python's [pandas](http://pandas.pydata.org/) package. Both packages expedite the often tedious process of acquiring & munging data and provide impressively well-developed and feature-rick toolkits for analysis.

Many thanks also to the developers/contributors to the current Julia [TimeSeries](https://github.com/JuliaStats/TimeSeries.jl), whose code I have referred to countless times as a resource while developing this package.

## Temporal vs. TimeSeries
The existing Julia type for representing time series objects is a reasonably reliable and robust solution. However, the motivation for developing `Temporal` and its flagship `TS` type was driven by a small number of design decisions and semantics used in `TimeSeries` that could arguably/subjectively prove inconvenient. A few that stood out as sufficient motivation for a new package are given below.

- A key difference is that Temporal's `TS` type is defined to be `mutable`, whereas the TimeSeries `TimeArray` type is defined to be `immutable`
    - Since in Julia, an object of `immutable` type "is passed around (both in assignment statements and in function calls) by copying, whereas a mutable type is passed around by reference" (see [here](https://docs.julialang.org/en/release-0.4/manual/types/#immutable-composite-types)), the `TS` type can be a more memory-efficient option
        - This assumes that proper care is taken to modify the object only when desired, a consideration inseparable from pass-by-reference semantics
    - Additionally, making the `TS` object `mutable` should provide greater ease & adaptability when modifying the object's fields
- Its indexing functionality operates differently than expected for the `Array` type, such that the `TimeArray` cannot be indexed in the same manner
    - For example, indexing columns must be done with `String`s, requiring `Array`-like indexing syntax to be done on the underlying `values` member of the object
    - Additionally, this difference in indexing syntax could cause confusion for newcomers and create unnecessary headaches in basic data munging and indexing tasks
    - The syntax is similar to that of the `DataFrame` class in Python. While this a familiar framework, R's `xts` class is functionally equivalent to the matrix clas
    - In like fashion, a goal of this package is for the `TS` type to behave like an `Array` as much as possible, but offer more flexibility when joining/merging through the use of *temporal- indexing, to simplify challenges uniquely associated with managing time series data structures
- Another difference between `TS` and `TimeSeries` lies in the existence of a "metadata" holder for the object
    - While this feature may be useful in some cases, the `TS` object will likely occupy less memory than an equivalent `TimeSeries` object, simply because it does not hold any metadata about the object
    - In cases where such underlying metadata is of use, there are likely ways to access it without attaching it to the object
- A deliberate stylistic decision was made in giving Temporal's time series type a compact name
    - While the `TimeSeries` package names its type `TimeArray`, typing out nine characters can slow one down when prototyping in the REPL
    - Creating a type alias is certainly a perfectly acceptable workaround, but only having to type `TS` (or `ts`) when constructing the type can save a considerable amount of time if you're experimenting in the REPL for any length of time
    - Additionally, if you don't want to type out field names every time you instantiate a new time series, the `TS` class will auto-populate field names for you

So in all, the differences between the two classes are relatively stylistic, but over time will hopefully increase efficiency both when writing and running code.

