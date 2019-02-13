# Temporal
This package provides a flexible & efficient time series class, `TS`, for the [Julia](http://julialang.org/) programming language. While still early in development, the overarching goal is for the class to be able to slice & dice data with the rapid prototyping speed of [R](https://www.r-project.org/)'s [`xts`](https://github.com/joshuaulrich/xts) and [Python](https://www.python.org/)'s [`pandas`](http://pandas.pydata.org/) packages, while retaining the performance one expects from Julia.

# Installation
`Temporal` can be easily installed using Julia's built-in package manager.

```@setup overview
using Temporal, Dates, Indicators, Plots, Pkg, Random
```

```@example overview
using Pkg
Pkg.add("Temporal")
using Temporal
```

# Introduction

## The `TS` Type

### Member Variables/Fields
`TS` objects store three member variables to facilitate data manipulation and analysis.
- `values`: an `Array` of the values of the time series data
- `index`: a `Vector` whose elements are either of type `Date` or `DateTime` indexing the values of the time series
- `fields`: a `Vector` whose elements are of type `Symbol` representing the column names of the time series data

### Construction
The `TS` object type can be created in a number of ways. One thing to note is that when constructing the `TS` object, passing only the `Array` of `values` will automatically create the `index` and the `fields` members. When not passed explicitly, the `index` defaults to a series of dates that ends with today's date, and begins `N-1` days before (where `N` is the number of rows of the `values`). The `fields` (or column names) are automatically set in a similar fashion as Excel when not given explicitly (A, B, C, ..., X, Y, Z, AA, AB, ...).

```@repl overview
using Temporal, Dates
N, K = (100, 4);
Random.seed!(1);
v = rand(N, K);
t = today()-Day(N-1):Day(1):today();
f = [:A, :B, :C, :D];
X = TS(v, t, f)
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
X .* Y
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
Crude = quandl("CHRIS/CME_CL1", from="2010-06-09", thru=string(Dates.today()), freq='w')  # Download weekly WTI crude oil price data
```

### Yahoo! Finance Downloads

```@repl overview
Snapchat = yahoo("SNAP", from="2017-03-03")  # Download historical prices for Snapchat since its IPO date
IBM_splits = yahoo("IBM", event="split")  # Get all stock splits in IBM's entire trading history
XOM_dividends = yahoo("XOM", event="div", from="2000-01-01", thru="2009-12-31")  # Get all divident payments Exxon disbursed during the 2000's
```

### Flat File Import

There are some sample data CSV files located in the Temporal package directory with some historical commodities prices for sample use (below file containing corn prices sourced from Quandl using the same "CHRIS" database).

```@repl overview
datafile = "$(Pkg.dir("Temporal"))/data/corn.csv";
corn = tsread(datafile)
```

## Indexing Functionality
Easily one of the more important parts of handling time series data is the ability to retrieve from that time series specific portions of the data that you want. To this end, `TS` objects provide a fairly flexible indexing interface to make it easier to slice & dice data in the ways commonly desired, while maintaining an emphasis on speed and performance wherever possible.

```@repl overview
crude = quandl("CHRIS/CME_CL1")  # Download crude oil prices from Quandl
```

### Numerical & range-based indexing

```@repl overview
crude[1]  # get the first row
crude[end,:]  # get the last row
crude[end-100:end, 1:4]

```

### Column/field indexing using Symbols
The `fields` member of the `Temporal.TS` object (wherein the column names are stored) are represented using julia's builtin `Symbol` datatype.

```@repl overview
crude[:Settle]
crude[[:Settle,:Volume]]
```

### Date indexing to select rows

```@repl overview
using Base.Dates
crude[today()]  # select the row corresponding to today's date
crude[collect(today()-Year(1):Day(1):today())]
```

### String-based date indexing
One of the features of R's xts package that I personally find most appealing is the ease with which one can subset out dates simply by passing easily readable character strings. `Temporal` implements this same logic for `TS` objects.

On a tangential note, it's interesting to observe that while this indexing logic is implemented in low-level `C` code in other packages, this logic has been implemented in pure julia, making it far easier to read, interpret, understand, debug, and/or adapt to one's own purposes.

```@repl overview
crude["2016"]  # retrieve all rows from the year 2016
crude["2015", 6]  # retrive the sixth column from 2015
crude["/2012", 1:4]  # retrieve first four columns for all rows through 2012
crude["2010/", end-2:end]  # retrieve last three columns for the year 2010 and on
crude["2014/2015", :Settle]  # retrieve settle prices for the years 2014 and 2015
```

## Merging, joining, and combining data

```@repl overview
gasoline = quandl("CHRIS/CME_RB1")
gasoline_settles = cl(gasoline)  # (note `cl` function will take fields named :Close, :AdjClose, :Settle, and :Last)
crude_settles = cl(crude)  # all OHLC(V) functions also implemented: op, hi, lo, cl, vo
crude_settles.fields[1] = :Crude;
A = ojoin(crude_settles, gasoline_settles)  # full outer join
A = [crude_settles gasoline_settles]  # hcat -- same as full outer join
A = dropnan(A)
A = [A randn(size(A,1))]  # can join to arrays of same size
A = [A 0];  # can join to single numbers as well
A
ijoin(crude_settles, gasoline_settles)  # inner join -- keep points in time where both objects have observations
ljoin(crude_settles, gasoline_settles)  # left join
rjoin(crude_settles, gasoline_settles)  # right join
fracker_era = [crude["/2013"]; crude["2016/"]]  # vertical concatenation also implemented!
avg_return_overall = mean(diff(log(cl(crude))))
avg_return_fracker = mean(diff(log(cl(fracker_era))))
```

## Aggregation/collapsing functionality

```@repl overview
eom(crude)  # Get the last values observed at the end of each month
[crude.index eom(crude.index)]  # (NOTE: the `eom` function returns a Boolean Vector when passed a Vector of TimeTypes)
collapse(crude, eom(crude.index), fun=mean)  # monthly averages for all columns
collapse(crude[:Volume], eoy(crude.index), fun=sum)  # Get the total yearly trading volume of crude oil
```

## Visualization

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

# Acknowledgements
This package is inspired mostly by R's [xts](https://github.com/joshuaulrich/xts) package and Python's [pandas](http://pandas.pydata.org/) package. Both packages expedite the often tedious process of acquiring & munging data and provide impressively well-developed and feature-rick toolkits for analysis.

Many thanks also to the developers/contributors to the current Julia [TimeSeries](https://github.com/JuliaStats/TimeSeries.jl), whose code I have referred to countless times as a resource while developing this package.

# Temporal vs. TimeSeries
The existing Julia type for representing time series objects is a reasonably reliable and robust solution. However, the motivation for developing `Temporal` and its flagship `TS` type was driven by a small number of design decisions and semantics used in `TimeSeries` that could arguably/subjectively prove inconvenient. A few that stood out as sufficient motivation for a new package are given below.

* A key difference is that Temporal's `TS` type is defined to be `mutable`, whereas the TimeSeries `TimeArray` type is defined to be `immutable`
    * Since in Julia, an object of `immutable` type "is passed around (both in assignment statements and in function calls) by copying, whereas a mutable type is passed around by reference" (see [here](https://docs.julialang.org/en/release-0.4/manual/types/#immutable-composite-types)), the `TS` type can be a more memory-efficient option
        * This assumes that proper care is taken to modify the object only when desired, a consideration inseparable from pass-by-reference semantics
    * Additionally, making the `TS` object `mutable` should provide greater ease & adaptability when modifying the object's fields
* Its indexing functionality operates differently than expected for the `Array` type, such that the `TimeArray` cannot be indexed in the same manner
    * For example, indexing columns must be done with `String`s, requiring `Array`-like indexing syntax to be done on the underlying `values` member of the object
    * Additionally, this difference in indexing syntax could cause confusion for newcomers and create unnecessary headaches in basic data munging and indexing tasks
    * The syntax is similar to that of the `DataFrame` class in Python. While this a familiar framework, R's `xts` class is functionally equivalent to the matrix clas
    * In like fashion, a goal of this package is for the `TS` type to behave like an `Array` as much as possible, but offer more flexibility when joining/merging through the use of *temporal* indexing, to simplify challenges uniquely associated with managing time series data structures
* Another difference between `TS` and `TimeSeries` lies in the existence of a "metadata" holder for the object
    * While this feature may be useful in some cases, the `TS` object will likely occupy less memory than an equivalent `TimeSeries` object, simply because it does not hold any metadata about the object
    * In cases where such underlying metadata is of use, there are likely ways to access it without attaching it to the object
* A deliberate stylistic decision was made in giving Temporal's time series type a compact name
    * While the `TimeSeries` package names its type `TimeArray`, typing out nine characters can slow one down when prototyping in the REPL
    * Creating a type alias is certainly a perfectly acceptable workaround, but only having to type `TS` (or `ts`) when constructing the type can save a considerable amount of time if you're experimenting in the REPL for any length of time
    * Additionally, if you don't want to type out field names every time you instantiate a new time series, the `TS` class will auto-populate field names for you

So in all, the differences between the two classes are relatively stylistic, but over time will hopefully increase efficiency both when writing and running code.

