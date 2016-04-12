# Temporal
This package provides a flexible & efficient time series class, `TS`, for the [Julia](http://julialang.org/) programming language. While still early in development, the overarching goal is for the class to be able to slice & dice data with the rapid prototyping speed of [R](https://www.r-project.org/)'s [`xts`](https://github.com/joshuaulrich/xts) and [Python](https://www.python.org/)'s [`pandas`](http://pandas.pydata.org/) packages, while retaining the performance one expects from Julia.

## Example

```julia
julia> using Temporal

julia> corn = tsread("$(Pkg.dir("Temporal"))/data/corn.csv")
14272x8 Temporal.TS{Float64,Date} 1959-07-01 to 2016-03-04

Index        Open      High      Low       Last      Change   Settle    Volume       Open Interest
1959-07-01 | 120.2     120.3     119.6     119.7     NaN      119.7     3952         13997
1959-07-02 | 119.6     120.0     119.2     119.6     NaN      119.6     2223         14047
1959-07-06 | 119.4     119.5     117.7     118.0     NaN      118.0     3121         14206
1959-07-07 | 118.1     118.5     118.0     118.3     NaN      118.3     3540         14142
...
2016-03-01 | 353.5     355.0     353.0     353.5     0.25     353.75    10558        16103
2016-03-02 | 353.75    355.5     352.5     354.25    0.75     354.5     2201         11204
2016-03-03 | 354.0     355.5     351.75    354.0     0.75     353.75    4021         9878
2016-03-04 | 354.0     357.75    353.5     355.0     0.75     354.5     2248         7846


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


julia> corn["2014::","Open Interest"]
548x1 Temporal.TS{Float64,Date} 2014-01-02 to 2016-03-04

Index        Open Interest
2014-01-02 | 644246
2014-01-03 | 643481
2014-01-06 | 646371
2014-01-07 | 642168
...
2016-03-01 | 16103
2016-03-02 | 11204
2016-03-03 | 9878
2016-03-04 | 7846


julia> corn["2010-06::2016-01-01",["Settle","Volume"]]
14272x2 Temporal.TS{Float64,Date} 1959-07-01 to 2016-03-04

Index        Settle    Volume
1959-07-01 | 119.7     3952
1959-07-02 | 119.6     2223
1959-07-06 | 118.0     3121
1959-07-07 | 118.3     3540
...
2016-03-01 | 353.75    10558
2016-03-02 | 354.5     2201
2016-03-03 | 353.75    4021
2016-03-04 | 354.5     2248
```

# TODO
- Add more methods for managing & cleaning data (`merge`, `dropnan`, `dropnil`, etc.)
- Allow non-numeric values in the array
- Add more operators and basic functions
- Temporal aggregation/collapsing
- ~~Add indexing functionality~~
    - ~~Index by row and column numbers/ranges~~
    - ~~Index rows by Date and DateTime types~~
    - ~~Index columns by field names~~
    - ~~Index rows by date strings (similar to R's `xts` class)~~
        - ~~`X["2012"]` should give all values in the year 2012~~
        - ~~`X["2012-06"]` should give all values in June 2012~~
        - ~~`X["2012::"]` should give all values from 2012 onwards~~

# Acknowledgements
This package is inspired mostly by R's [xts](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwi0yPm9yN3KAhXBfyYKHSACCzMQFggdMAA&url=https%3A%2F%2Fcran.r-project.org%2Fweb%2Fpackages%2Fxts%2Fxts.pdf&usg=AFQjCNHpel8f8UzrzErz6U1SOfNnnSg6_g&sig2=K_omBmBbNMtjUfJ8mt-eOQ) package and Python's [pandas](http://pandas.pydata.org/) package. Both packages expedite the often tedious process of acquiring & munging data and provide impressively well-developed and feature-rick toolkits for analysis.

Many thanks also to the developers/contributors to the current Julia [TimeSeries](https://github.com/JuliaStats/TimeSeries.jl), whose code I have referred to countless times as a resource while developing this package.

# Temporal vs. TimeSeries
The existing Julia type for representing time series objects is definitely a reliable and robust solution. However, its indexing functionality operates differently than expected for the `Array` type, which could potentially cause confusion and pose problems for portability in the future. The syntax is similar to that of the `DataFrame` class in Python. While this a familiar framework, R's `xts` class is functionally equivalent to the matrix class; in like fashion, a goal of this package is for the `TS` type to behave like an `Array` as much as possible, but offer more flexibility joining/merging through the use of temporal indexing.

Another difference between `TS` and `TimeSeries` lies in the existence of a "metadata" holder for the object. While this feature may be useful in some cases, the `TS` object will occupy less memory than an equivalent `TimeSeries` object, simply because it does not hold any metadata about the object. In cases where such underlying metadata is of use, there are likely ways to access it without attaching it to the object.

Finally, a deliberate stylistic decision was made in giving Temporal's time series type a compact name. While the `TimeSeries` package names its type `TimeArray`, typing out nine characters can slow one down when prototyping in the REPL. Creating a type alias is certainly a perfectly acceptable workaround, but only having to type `TS` (or `ts`) when constructing the type can save a considerable amount of time if you're experimenting in the REPL for any length of time. Additionally, if you don't want to type out field names every time you instantiate a new time series, the `TS` class will auto-populate field names for you. 

So in all, the differences between the two classes are relatively stylistic, but over time will hopefully increase efficiency both when writing and running code.


[![Build Status](https://travis-ci.org/dysonance/Temporal.jl.svg?branch=master)](https://travis-ci.org/dysonance/Temporal.jl)
