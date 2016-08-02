[![Build Status](https://travis-ci.org/dysonance/Temporal.jl.svg?branch=master)](https://travis-ci.org/dysonance/Temporal.jl)

# Temporal
This package provides a flexible & efficient time series class, `TS`, for the [Julia](http://julialang.org/) programming language. While still early in development, the overarching goal is for the class to be able to slice & dice data with the rapid prototyping speed of [R](https://www.r-project.org/)'s [`xts`](https://github.com/joshuaulrich/xts) and [Python](https://www.python.org/)'s [`pandas`](http://pandas.pydata.org/) packages, while retaining the performance one expects from Julia.

## Example

### Indexing functionality

```julia
julia> using Temporal

# Read in a csv of historical data on CBOT corn futures
julia> corn = tsread("$(Pkg.dir("Temporal"))/data/corn.csv")
14272x8 Temporal.TS{Float64,Date} 1959-07-01 to 2016-03-04

Index        Open      High      Low       Last      Change   Settle    Volume       OpenInterest
1959-07-01 | 120.2     120.3     119.6     119.7     NaN      119.7     3952         13997
1959-07-02 | 119.6     120.0     119.2     119.6     NaN      119.6     2223         14047
1959-07-06 | 119.4     119.5     117.7     118.0     NaN      118.0     3121         14206
1959-07-07 | 118.1     118.5     118.0     118.3     NaN      118.3     3540         14142
...
2016-03-01 | 353.5     355.0     353.0     353.5     0.25     353.75    10558        16103
2016-03-02 | 353.75    355.5     352.5     354.25    0.75     354.5     2201         11204
2016-03-03 | 354.0     355.5     351.75    354.0     0.75     353.75    4021         9878
2016-03-04 | 354.0     357.75    353.5     355.0     0.75     354.5     2248         7846

# Numerical & range-based indexing
julia> corn[end-100:end,1:4]
101x4 Temporal.TS{Float64,Date} 2015-10-09 to 2016-03-04

Index        Open      High      Low       Last
2015-10-09 | 391.0     394.25    381.5     382.25
2015-10-12 | 381.5     385.25    380.25    380.75
2015-10-13 | 381.0     384.75    379.0     384.25
2015-10-14 | 384.5     386.75    378.5     378.5
...
2016-03-01 | 353.5     355.0     353.0     353.5
2016-03-02 | 353.75    355.5     352.5     354.25
2016-03-03 | 354.0     355.5     351.75    354.0
2016-03-04 | 354.0     357.75    353.5     355.0

# String-based Date/DateTime indexing
julia> corn["2016"]
43x8 Temporal.TS{Float64,Date} 2016-01-04 to 2016-03-04

Index        Open      High      Low       Last      Change  Settle    Volume       OpenInterest
2016-01-04 | 359.5     360.0     350.5     352.0     7.25    351.5     170742       714792
2016-01-05 | 352.75    356.0     351.75    353.0     1.5     353.0     131960       727298
2016-01-06 | 353.5     354.75    350.25    353.25    0.25    353.25    124631       730600
2016-01-07 | 353.25    354.25    348.5     353.0     0.25    353.0     137217       727995
...
2016-03-01 | 353.5     355.0     353.0     353.5     0.25    353.75    10558        16103
2016-03-02 | 353.75    355.5     352.5     354.25    0.75    354.5     2201         11204
2016-03-03 | 354.0     355.5     351.75    354.0     0.75    353.75    4021         9878
2016-03-04 | 354.0     357.75    353.5     355.0     0.75    354.5     2248         7846

julia> corn["2015",6]
253x1 Temporal.TS{Float64,Date} 2015-01-02 to 2015-12-31

Index        Settle
2015-01-02 | 395.5
2015-01-05 | 406.0
2015-01-06 | 405.0
2015-01-07 | 396.5
...
2015-12-28 | 361.0
2015-12-29 | 362.5
2015-12-30 | 359.0
2015-12-31 | 358.75

# Symbol-based indexing for access to fields (columns)
julia> corn[:Settle]
14272x1 Temporal.TS{Float64,Date} 1959-07-01 to 2016-03-04

Index        Settle
1959-07-01 | 119.7
1959-07-02 | 119.6
1959-07-06 | 118.0
1959-07-07 | 118.3
...
2016-03-01 | 353.75
2016-03-02 | 354.5
2016-03-03 | 353.75
2016-03-04 | 354.5

# Get the open interest from 2014 onwards
# (Notice columns are stored as Symbol types)
julia> corn["2014/", :OpenInterest]
548x1 Temporal.TS{Float64,Date} 2014-01-02 to 2016-03-04

Index        OpenInterest
2014-01-02 | 644246
2014-01-03 | 643481
2014-01-06 | 646371
2014-01-07 | 642168
...
2016-03-01 | 16103
2016-03-02 | 11204
2016-03-03 | 9878
2016-03-04 | 7846

# Get the volume and settle prices from June 2010 through January 1, 2016
julia> corn["2010-06/2016-01-01", [:Settle, :Volume]]
1408x2 Temporal.TS{Float64,Date} 2010-06-01 to 2015-12-31

Index        Settle    Volume
2010-06-01 | 354.0     150749
2010-06-02 | 348.5     137372
2010-06-03 | 349.5     127867
2010-06-04 | 340.0     141195
...
2015-12-28 | 361.0     89773
2015-12-29 | 362.5     112101
2015-12-30 | 359.0     90945
2015-12-31 | 358.75    68098
```

### Aggregation functionality
```julia
# Get the values observed at the end of each month
julia> eom(corn)
680x8 Temporal.TS{Float64,Date} 1959-07-31 to 2016-02-29

Index        Open      High      Low       Last      Change   Settle    Volume       OpenInterest
1959-07-31 | 119.2     120.0     119.2     119.7     NaN      119.7     1868         16381
1959-08-31 | 116.4     118.0     116.2     117.7     NaN      117.7     2865         10008
1959-09-30 | 109.4     109.6     109.1     109.6     NaN      109.6     2094         28224
1959-10-30 | 109.6     110.3     109.6     110.1     NaN      110.1     4819         24897
...
2015-11-30 | 359.75    366.0     359.25    366.0     5.75     365.0     31892        33153
2015-12-31 | 358.5     360.25    357.5     358.25    0.25     358.75    68098        709297
2016-01-29 | 365.25    372.5     365.0     371.25    6.5      372.0     201077       606956
2016-02-29 | 355.0     357.0     353.0     353.5     1.0      353.5     21576        23849

# Monthly averages for all columns
# (Note the eom function returns a Boolean Array when passed a Vector of Dates/DateTimes)
# (Here it's returning a BitArray where true corresponds with an end of month)
julia> aggregate(corn, eom(corn.index), fun=mean)
679x8 Temporal.TS{Float64,Date} 1959-08-31 to 2016-02-29

Index        Open      High      Low       Last      Change  Settle    Volume       OpenInterest
1959-08-31 | 118.9682  119.4227  118.5591  118.9409  NaN     118.9409  2194.0455    14161.8182
1959-09-30 | 114.2909  114.7318  113.7364  114.2364  NaN     114.2364  2270.2273    14365.8636
1959-10-30 | 109.5783  109.9565  109.3     109.6609  NaN     109.6609  3306.5652    27128.5652
1959-11-30 | 111.5381  112.0762  111.2714  111.5571  NaN     111.5571  4837.7143    22800.0952
...
2015-11-30 | 367.5714  370.0595  364.3929  367.0833  NaN     367.0714  203331.8571  399415.2857
2015-12-31 | 369.0761  372.1957  365.9891  369.0652  3.4891  369.0109  68823.6087   400381.4348
2016-01-29 | 361.0125  364.45    358.475   361.35    NaN     361.6875  186723.6     686595.05
2016-02-29 | 364.2976  366.2619  361.9167  363.4762  NaN     363.6905  165292.0952  385815.2381

# Get the total yearly volume of corn trades
julia> aggregate(corn[:,:Volume], eoy(corn.index), fun=sum)
56x1 Temporal.TS{Float64,Date} 1960-12-30 to 2015-12-31

Index        Volume
1960-12-30 | 701879
1961-12-29 | 883770
1962-12-31 | 1683139
1963-12-31 | 1664762
...
2012-12-31 | 27646335
2013-12-31 | 24461763
2014-12-31 | 28156562
2015-12-31 | 32270808
```

# Acknowledgements
This package is inspired mostly by R's [xts](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwi0yPm9yN3KAhXBfyYKHSACCzMQFggdMAA&url=https%3A%2F%2Fcran.r-project.org%2Fweb%2Fpackages%2Fxts%2Fxts.pdf&usg=AFQjCNHpel8f8UzrzErz6U1SOfNnnSg6_g&sig2=K_omBmBbNMtjUfJ8mt-eOQ) package and Python's [pandas](http://pandas.pydata.org/) package. Both packages expedite the often tedious process of acquiring & munging data and provide impressively well-developed and feature-rick toolkits for analysis.

Many thanks also to the developers/contributors to the current Julia [TimeSeries](https://github.com/JuliaStats/TimeSeries.jl), whose code I have referred to countless times as a resource while developing this package.

# Temporal vs. TimeSeries
The existing Julia type for representing time series objects is definitely a reliable and robust solution. However, its indexing functionality operates differently than expected for the `Array` type, which could potentially cause confusion and pose problems for portability in the future. The syntax is similar to that of the `DataFrame` class in Python. While this a familiar framework, R's `xts` class is functionally equivalent to the matrix class; in like fashion, a goal of this package is for the `TS` type to behave like an `Array` as much as possible, but offer more flexibility joining/merging through the use of temporal indexing.

Another difference between `TS` and `TimeSeries` lies in the existence of a "metadata" holder for the object. While this feature may be useful in some cases, the `TS` object will occupy less memory than an equivalent `TimeSeries` object, simply because it does not hold any metadata about the object. In cases where such underlying metadata is of use, there are likely ways to access it without attaching it to the object.

Finally, a deliberate stylistic decision was made in giving Temporal's time series type a compact name. While the `TimeSeries` package names its type `TimeArray`, typing out nine characters can slow one down when prototyping in the REPL. Creating a type alias is certainly a perfectly acceptable workaround, but only having to type `TS` (or `ts`) when constructing the type can save a considerable amount of time if you're experimenting in the REPL for any length of time. Additionally, if you don't want to type out field names every time you instantiate a new time series, the `TS` class will auto-populate field names for you. 

So in all, the differences between the two classes are relatively stylistic, but over time will hopefully increase efficiency both when writing and running code.
