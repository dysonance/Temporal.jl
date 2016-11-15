[![Build Status](https://travis-ci.org/dysonance/Temporal.jl.svg?branch=master)](https://travis-ci.org/dysonance/Temporal.jl)

# Temporal
This package provides a flexible & efficient time series class, `TS`, for the [Julia](http://julialang.org/) programming language. While still early in development, the overarching goal is for the class to be able to slice & dice data with the rapid prototyping speed of [R](https://www.r-project.org/)'s [`xts`](https://github.com/joshuaulrich/xts) and [Python](https://www.python.org/)'s [`pandas`](http://pandas.pydata.org/) packages, while retaining the performance one expects from Julia.

# Example

## Indexing functionality

```julia
julia> using Temporal


# Download crude oil prices from Quandl
julia> crude = quandl("CHRIS/CME_CL1", from="2010-01-01")
1732x8 Temporal.TS{Float64,Date}: 2010-01-04 to 2016-11-14

Index       Open    High    Low     Last    Change  Settle  Volume      OpenInterest
2010-01-04  79.63   81.79   79.63   81.51   NaN     81.51   263542      290352
2010-01-05  81.77   81.77   81.77   81.77   NaN     81.77   258887      280580
2010-01-06  81.43   83.52   80.85   83.18   NaN     83.18   370059      275043
2010-01-07  83.2    83.36   82.26   82.66   NaN     82.66   246632      262309
2010-01-08  82.65   83.47   81.8    82.75   NaN     82.75   310377      250371
...
2016-11-08  44.97   45.39   44.41   44.83   0.09    44.98   639596      460444
2016-11-09  44.82   45.95   43.07   45.34   0.29    45.27   917220      413672
2016-11-10  45.31   45.64   44.25   44.29   0.61    44.66   660149      375825
2016-11-11  44.35   44.63   43.03   43.12   1.25    43.41   616195      333522
2016-11-14  43.2    43.81   42.2    43.72   0.09    43.32   689622      304212


# Download Exxon mobile stock prices from Yahoo Finance
julia> exxon = yahoo("XOM", from="2010-01-01")
1730x6 Temporal.TS{Float64,Date}: 2010-01-04 to 2016-11-14

Index       Open    High    Low     Close   Volume        AdjClose
2010-01-04  68.72   69.26   68.19   69.15   27809100      56.701
2010-01-05  69.19   69.45   68.8    69.42   30174700      56.9223
2010-01-06  69.45   70.6    69.34   70.02   35044700      57.4143
2010-01-07  69.9    70.06   69.42   69.8    27192100      57.2339
2010-01-08  69.69   69.75   69.22   69.52   24891800      57.0043
...
2016-11-08  84.73   85.83   84.49   85.31   9735200       85.31
2016-11-09  84.05   86.71   83.66   86.25   15800200      86.25
2016-11-10  85.91   87.99   85.66   87.05   14106100      87.05
2016-11-11  86.53   86.73   84.89   85.67   13711000      85.67
2016-11-14  85.3    85.65   84.33   85.28   12553200      85.28


# Numerical & range-based indexing
julia> crude[end-100:end, 1:4]
101x4 Temporal.TS{Float64,Date}: 2016-06-23 to 2016-11-14

Index       Open   High   Low    Last
2016-06-23  49.08  50.23  49.08  50.13
2016-06-24  50.3   50.45  46.7   47.57
2016-06-27  47.81  47.96  45.83  46.61
2016-06-28  46.59  48.18  46.54  48.11
2016-06-29  48.06  50.0   47.98  49.54
...
2016-11-08  44.97  45.39  44.41  44.83
2016-11-09  44.82  45.95  43.07  45.34
2016-11-10  45.31  45.64  44.25  44.29
2016-11-11  44.35  44.63  43.03  43.12
2016-11-14  43.2   43.81  42.2   43.72


# String-based date indexing
julia> crude["2016"]
220x8 Temporal.TS{Float64,Date}: 2016-01-04 to 2016-11-14

Index       Open   High   Low    Last   Change  Settle  Volume      OpenInterest
2016-01-04  37.6   38.39  36.33  36.88  0.28    36.76   426831      437108
2016-01-05  36.9   37.1   35.74  36.14  0.79    35.97   408389      437506
2016-01-06  36.18  36.39  33.77  34.06  2.0     33.97   528347      436383
2016-01-07  34.09  34.26  32.1   33.26  0.7     33.27   590277      431502
2016-01-08  33.3   34.34  32.64  32.88  0.11    33.16   567056      404315
...
2016-11-08  44.97  45.39  44.41  44.83  0.09    44.98   639596      460444
2016-11-09  44.82  45.95  43.07  45.34  0.29    45.27   917220      413672
2016-11-10  45.31  45.64  44.25  44.29  0.61    44.66   660149      375825
2016-11-11  44.35  44.63  43.03  43.12  1.25    43.41   616195      333522
2016-11-14  43.2   43.81  42.2   43.72  0.09    43.32   689622      304212


# Can mix & match indexing methods as well
julia> crude["2015",6]
252x1 Temporal.TS{Float64,Date}: 2015-01-02 to 2015-12-31

Index       Settle
2015-01-02  52.69
2015-01-05  50.04
2015-01-06  47.93
2015-01-07  48.65
2015-01-08  48.79
...
2015-12-24  38.1
2015-12-28  36.81
2015-12-29  37.87
2015-12-30  36.6
2015-12-31  37.04


# Use Symbols (or Vectors of Symbols) to access specific columns/fields
julia> crude[:Settle]
1732x1 Temporal.TS{Float64,Date}: 2010-01-04 to 2016-11-14

Index       Settle
2010-01-04  81.51
2010-01-05  81.77
2010-01-06  83.18
2010-01-07  82.66
2010-01-08  82.75
...
2016-11-08  44.98
2016-11-09  45.27
2016-11-10  44.66
2016-11-11  43.41
2016-11-14  43.32


# Can access date ranges/regions using the '/' character in String-based row indexing
julia> crude["2014/", :OpenInterest]
724x1 Temporal.TS{Float64,Date}: 2014-01-02 to 2016-11-14

Index       OpenInterest
2014-01-02  253407
2014-01-03  248008
2014-01-06  239297
2014-01-07  229314
2014-01-08  206164
...
2016-11-08  460444
2016-11-09  413672
2016-11-10  375825
2016-11-11  333522
2016-11-14  304212


# Get settles and volume for crude oil from June 2010 through January 1, 2016
julia> crude["2010-06/2016-01-01", [:Settle,:Volume]]
1410x2 Temporal.TS{Float64,Date}: 2010-06-01 to 2015-12-31

Index       Settle  Volume
2010-06-01  72.58   438588
2010-06-02  72.86   391034
2010-06-03  74.61   439431
2010-06-04  71.51   448494
2010-06-07  71.44   417308
...
2015-12-24  38.1    201502
2015-12-28  36.81   217992
2015-12-29  37.87   239759
2015-12-30  36.6    261808
2015-12-31  37.04   279553
```

## Aggregation/collapsing functionality

```julia
# Get the last values observed at the end of each month
julia> eom(crude)
82x8 Temporal.TS{Float64,Date}: 2010-01-29 to 2016-10-31

Index       Open    High    Low     Last    Change  Settle  Volume     OpenInterest
2010-01-29  73.89   74.82   72.43   72.89   NaN     72.89   335270     342928
2010-02-26  78.33   80.05   77.82   79.66   NaN     79.66   319038     259774
2010-03-31  82.5    83.85   82.22   83.76   NaN     83.76   244435     313903
2010-04-30  85.58   86.5    85.16   86.15   NaN     86.15   392139     355407
2010-05-28  74.9    75.72   73.13   73.97   NaN     73.97   420674     374848
...
2016-06-30  49.55   49.62   48.17   48.4    1.55    48.33   507204     456058
2016-07-29  41.12   41.67   40.57   41.38   0.46    41.6    473289     535100
2016-08-31  46.24   46.41   44.51   44.86   1.65    44.7    540066     435848
2016-09-30  47.76   48.3    47.04   48.05   0.41    48.24   488905     539955
2016-10-31  48.25   48.74   46.63   46.76   1.84    46.86   638515     483961


# (NOTE: the `eom` function returns a Boolean Vector when passed a Vector of TimeTypes)
julia> [crude.index eom(crude.index)]
1732x2 Array{Any,2}:
2010-01-04  false
2010-01-05  false
2010-01-06  false
2010-01-07  false
2010-01-08  false
2010-01-11  false
2010-01-12  false
2010-01-13  false
2010-01-14  false
2010-01-15  false
2010-01-19  false
2010-01-20  false
2010-01-21  false
2010-01-22  false
2010-01-25  false
...
2016-10-25  false
2016-10-26  false
2016-10-27  false
2016-10-28  false
2016-10-31   true
2016-11-01  false
2016-11-02  false
2016-11-03  false
2016-11-04  false
2016-11-07  false
2016-11-08  false
2016-11-09  false
2016-11-10  false
2016-11-11  false
2016-11-14  false


# Monthly averages for all columns
# (Here the second argument is a Boolean Vector where trues correspond to aggregation period endings)
julia> collapse(crude, eom(crude.index), fun=mean)
81x8 Temporal.TS{Float64,Date}: 2010-02-26 to 2016-10-31

Index       Open    High    Low     Last    Change  Settle  Volume     OpenInterest
2010-02-26  76.0705 77.2435 74.7395 76.2745 NaN     76.2745 350321.35  214837.55
2010-03-31  81.0567 82.0    80.0954 81.2221 NaN     81.2221 284480.5833212291.5
2010-04-30  84.3727 85.3077 83.3286 84.5382 NaN     84.5382 334260.4545253902.4091
2010-05-28  75.4114 76.5157 73.3662 74.6905 NaN     74.6905 399089.5714274426.381
2010-06-30  75.2157 76.4783 74.0148 75.3422 NaN     75.3422 338047.5652233670.6522
...
2016-06-30  48.9117 49.6143 48.0165 48.7996 0.9965  48.8639 465633.0435364372.3913
2016-07-29  45.381  45.95   44.3529 44.9667 0.9805  44.9676 458506.7619356436.7143
2016-08-31  44.4863 45.295  43.7938 44.6371 0.9058  44.6658 492088.7917371972.9583
2016-09-30  45.1736 46.0536 44.3555 45.2273 1.1145  45.2018 575717.4545381343.9091
2016-10-31  49.8577 50.4759 49.1723 49.8282 0.685   49.8627 503668.8636373368.4091


# Get the total yearly trading volume of crude oil
julia> collapse(crude[:Volume], eoy(crude.index), fun=sum)
5x1 Temporal.TS{Float64,Date}: 2011-12-30 to 2015-12-31

Index       Volume
2011-12-30  79977769
2012-12-31  58497296
2013-12-31  54772321
2014-12-31  62231021
2015-12-31  91792816
```

# Acknowledgements
This package is inspired mostly by R's [xts](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwi0yPm9yN3KAhXBfyYKHSACCzMQFggdMAA&url=https%3A%2F%2Fcran.r-project.org%2Fweb%2Fpackages%2Fxts%2Fxts.pdf&usg=AFQjCNHpel8f8UzrzErz6U1SOfNnnSg6_g&sig2=K_omBmBbNMtjUfJ8mt-eOQ) package and Python's [pandas](http://pandas.pydata.org/) package. Both packages expedite the often tedious process of acquiring & munging data and provide impressively well-developed and feature-rick toolkits for analysis.

Many thanks also to the developers/contributors to the current Julia [TimeSeries](https://github.com/JuliaStats/TimeSeries.jl), whose code I have referred to countless times as a resource while developing this package.

# Temporal vs. TimeSeries
The existing Julia type for representing time series objects is definitely a reliable and robust solution. However, its indexing functionality operates differently than expected for the `Array` type, which could potentially cause confusion and pose problems for portability in the future. The syntax is similar to that of the `DataFrame` class in Python. While this a familiar framework, R's `xts` class is functionally equivalent to the matrix class; in like fashion, a goal of this package is for the `TS` type to behave like an `Array` as much as possible, but offer more flexibility joining/merging through the use of temporal indexing.

Another difference between `TS` and `TimeSeries` lies in the existence of a "metadata" holder for the object. While this feature may be useful in some cases, the `TS` object will occupy less memory than an equivalent `TimeSeries` object, simply because it does not hold any metadata about the object. In cases where such underlying metadata is of use, there are likely ways to access it without attaching it to the object.

Finally, a deliberate stylistic decision was made in giving Temporal's time series type a compact name. While the `TimeSeries` package names its type `TimeArray`, typing out nine characters can slow one down when prototyping in the REPL. Creating a type alias is certainly a perfectly acceptable workaround, but only having to type `TS` (or `ts`) when constructing the type can save a considerable amount of time if you're experimenting in the REPL for any length of time. Additionally, if you don't want to type out field names every time you instantiate a new time series, the `TS` class will auto-populate field names for you. 

So in all, the differences between the two classes are relatively stylistic, but over time will hopefully increase efficiency both when writing and running code.
