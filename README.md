# Temporal
This package provides a flexible & efficient time series class, `TS`, for the Julia programming language. While still early in development, the overarching goal is for the class to be able to slice & dice data with the rapid prototyping speed of R's `xts` and Python's `pandas` packages, while retaining the performance one expects from Julia.

# Example

```julia
# sample toy random data
n = 100  # number of observations
k = 4  # number of columns/fields
x0 = 50.0  # starting value of random walk
flds = [string("V",j) for j=1:k]  # field/column names
V = cumsum(randn(n,k))+x0  # multivariate (matrix)
v = cumsum(randn(n))+x0    # univariate (vector)
t = [Dates.today() + Dates.Day(i) for i=1:n]  # series of n dates
x = TS(v, t)
X = TS(V, t, flds)
```

```
julia> x
100x1 TS{Float64,Date,ByteString} 2016-02-05 to 2016-05-14

Index        V1
2016-02-05 | 50.5852
2016-02-06 | 49.8508
2016-02-07 | 49.6283
2016-02-08 | 50.1008
...
2016-05-11 | 60.6536
2016-05-12 | 59.9373
2016-05-13 | 57.6308
2016-05-14 | 55.8239


julia> X
100x4 TS{Float64,Date,ByteString} 2016-02-05 to 2016-05-14

Index        V1       V2       V3       V4
2016-02-05 | 50.1264  51.4204  48.9211  49.6142
2016-02-06 | 50.3654  50.3024  48.8539  50.3364
2016-02-07 | 49.7608  50.443   47.8611  51.9127
2016-02-08 | 49.642   48.7189  48.4467  52.4475
...
2016-05-11 | 54.006   51.3708  33.6298  47.3238
2016-05-12 | 55.238   52.6768  32.3461  47.9256
2016-05-13 | 56.6052  53.6904  32.1362  47.4463
2016-05-14 | 55.0082  54.9423  33.2523  46.6366
```

# TODO
- Add indexing functionality
	- ~~Index by row and column numbers/ranges~~
	- Index columns by field names
	- Index rows by date
		- `X["2012"]` should give all values in the year 2012
		- `X["2012-06"]` should give all values in June 2012
		- `X["2012::"]` should give all values from 2012 onwards
		- `X[Date("2012-06-15"):Date("2012-06-30")]` should give all values matching the corresponding date range
- Add methods for managing & cleaning data (i.e. `merge` methods)
- Add mathematical operators
- Allow non-numeric values in the array

# Acknowledgements
This package is inspired mostly by R's [xts](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwi0yPm9yN3KAhXBfyYKHSACCzMQFggdMAA&url=https%3A%2F%2Fcran.r-project.org%2Fweb%2Fpackages%2Fxts%2Fxts.pdf&usg=AFQjCNHpel8f8UzrzErz6U1SOfNnnSg6_g&sig2=K_omBmBbNMtjUfJ8mt-eOQ) package and Python's [pandas](http://pandas.pydata.org/) package. Both packages expedite the often tedious process of acquiring & munging data and provide impressively well-developed and feature-rick toolkits for analysis.

Many thanks also to the developers/contributors to the current Julia [TimeSeries](https://github.com/JuliaStats/TimeSeries.jl), whose code I have referred to countless times as a resource while developing this package.


[![Build Status](https://travis-ci.org/dysonance/Temporal.jl.svg?branch=master)](https://travis-ci.org/dysonance/Temporal.jl)
