# Temporal
This package provides a flexible & efficient time series class, `TS`, for the Julia programming language. While still early in development, the overarching goal is for the class to be able to slice & dice data with the rapid prototyping speed of R's `xts` and Python's `pandas` packages, while retaining the performance one expects from Julia.

## Example

```julia
vector = 50.0 + cumsum(randn(100))
stamps = collect(today():today()+Day(99))
matrix = [vector vector+rand(100) vector-rand(100)]
fields = ["A", "B", "C"]
A = ts(matrix, stamps)  # no fields specified
B = ts(matrix, stamps, fields)  # field names A, B, and C
```

Now that we have a couple time series toy datasets to play with...

```
julia> A
100x3 Temporal.TS{Float64,Date,ByteString} 2016-02-25 to 2016-06-03

Index        V1       V2       V3       
2016-02-25 | 47.21    47.31    47.1125  
2016-02-26 | 46.4354  47.0957  45.6798  
2016-02-27 | 46.3384  46.6943  45.6611  
2016-02-28 | 47.0028  47.7949  46.4863  
...
2016-05-31 | 45.7467  46.5664  45.2914  
2016-06-01 | 47.4027  47.6903  47.2117  
2016-06-02 | 47.7593  48.4525  47.6897  
2016-06-03 | 46.3225  47.1005  46.2786  


julia> B
100x3 Temporal.TS{Float64,Date,ASCIIString} 2016-02-25 to 2016-06-03

Index        A        B        C        
2016-02-25 | 47.21    47.31    47.1125  
2016-02-26 | 46.4354  47.0957  45.6798  
2016-02-27 | 46.3384  46.6943  45.6611  
2016-02-28 | 47.0028  47.7949  46.4863  
...
2016-05-31 | 45.7467  46.5664  45.2914  
2016-06-01 | 47.4027  47.6903  47.2117  
2016-06-02 | 47.7593  48.4525  47.6897  
2016-06-03 | 46.3225  47.1005  46.2786  


julia> A[1:10]
10x3 Temporal.TS{Float64,Date,ByteString} 2016-02-25 to 2016-03-05

Index        V1       V2       V3       
2016-02-25 | 47.21    47.31    47.1125  
2016-02-26 | 46.4354  47.0957  45.6798  
2016-02-27 | 46.3384  46.6943  45.6611  
2016-02-28 | 47.0028  47.7949  46.4863  
...
2016-03-02 | 47.2807  47.4007  46.6933  
2016-03-03 | 48.3931  48.948   48.0837  
2016-03-04 | 51.0334  51.1678  50.9864  
2016-03-05 | 50.8235  51.5169  49.8334  


julia> B[2:10,2]
9x1 Temporal.TS{Float64,Date,ASCIIString} 2016-02-26 to 2016-03-05

Index        B        
2016-02-26 | 47.0957  
2016-02-27 | 46.6943  
2016-02-28 | 47.7949  
2016-02-29 | 45.7368  
...
2016-03-02 | 47.4007  
2016-03-03 | 48.948   
2016-03-04 | 51.1678  
2016-03-05 | 51.5169 
```

# TODO
- Add methods for managing & cleaning data (`merge`, `dropnan`, `dropnil`, etc.)
- Add operators
- Allow non-numeric values in the array
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
