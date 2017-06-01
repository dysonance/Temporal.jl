[![Build Status](https://travis-ci.org/dysonance/Temporal.jl.svg?branch=master)](https://travis-ci.org/dysonance/Temporal.jl)

# Temporal
This package provides a flexible & efficient time series class, `TS`, for the [Julia](http://julialang.org/) programming language. While still early in development, the overarching goal is for the class to be able to slice & dice data with the rapid prototyping speed of [R](https://www.r-project.org/)'s [`xts`](https://github.com/joshuaulrich/xts) and [Python](https://www.python.org/)'s [`pandas`](http://pandas.pydata.org/) packages, while retaining the performance one expects from Julia.

# Installation
`Temporal` can be easily installed using Julia's built-in package manager.
```julia
julia> Pkg.add("Temporal")

julia> using Temporal
```

# Examples

## Data Input/Output
There are currently several options for how to get time series data into the Julia environment as `Temporal.TS` objects.
- Data Vendor Downloads
    - Quandl
    - Yahoo! Finance
    - Google Finance
- Local Flat Files (CSV, TSV, etc.)


### Quandl Data Downloads
```julia
# Download weekly WTI crude oil price data
julia> Crude = quandl("CHRIS/CME_CL1",
                      from="2010-06-09",
                      thru=string(Dates.today()),
                      freq='w')
365x8 Temporal.TS{Float64,Date}: 2010-06-13 to 2017-06-04
Index       Open   High   Low    Last   Change  Settle  Volume     PreviousDayOpenInterest  
2010-06-13  75.52  75.64  73.26  73.78  NaN     73.78   421739.0   156818.0                 
2010-06-20  76.55  77.45  75.56  77.18  NaN     77.18   157434.0   51860.0                  
2010-06-27  76.56  79.19  75.9   78.86  NaN     78.86   316456.0   309630.0                 
2010-07-04  72.67  73.38  71.62  72.14  NaN     72.14   256171.0   300301.0                 
2010-07-11  75.85  76.48  75.0   76.09  NaN     76.09   269887.0   233075.0                 
2010-07-18  76.82  77.15  75.25  76.01  NaN     76.01   225250.0   59046.0                  
2010-07-25  79.27  79.6   78.4   78.98  NaN     78.98   259741.0   364806.0                 
2010-08-01  78.25  79.05  76.83  78.95  NaN     78.95   294425.0   338723.0                 
⋮
2017-04-09  51.7   52.94  51.49  52.29  0.54    52.24   767404.0   482370.0                 
2017-04-16  52.85  53.39  52.82  52.91  0.07    53.18   468463.0   211355.0                 
2017-04-23  50.71  50.93  49.2   49.63  1.09    49.62   679261.0   620206.0                 
2017-04-30  49.27  49.76  48.8   49.19  0.36    49.33   629561.0   591781.0                 
2017-05-07  45.51  46.68  43.76  46.47  0.7     46.22   1.01503e6  577422.0                 
2017-05-14  47.81  48.07  47.35  47.82  0.01    47.84   527587.0   338671.0                 
2017-05-21  49.28  50.53  49.28  50.53  0.98    50.33   139324.0   74015.0                  
2017-05-28  48.75  49.94  48.18  49.87  0.9     49.8    759936.0   578141.0                 
2017-06-04  49.93  50.28  49.03  49.65  0.14    49.66   659013.0   576777.0
```

### Yahoo! Finance Downloads
```julia
# Download historical prices for Snapchat since its IPO date
Snapchat = yahoo("SNAP", from="2017-03-03")
61x6 Temporal.TS{Float64,Date}: 2017-03-03 to 2017-05-30
Index       Open   High   Low    Close  AdjClose  Volume      
2017-03-03  26.39  29.44  26.06  27.09  27.09     1.481664e8  
2017-03-06  28.17  28.25  23.77  23.77  23.77     7.2903e7    
2017-03-07  22.21  22.5   20.64  21.44  21.44     7.18578e7   
2017-03-08  22.03  23.43  21.31  22.81  22.81     4.98191e7   
2017-03-09  23.17  23.68  22.51  22.71  22.71     2.58032e7   
2017-03-10  23.36  23.4   22.0   22.07  22.07     1.83376e7   
2017-03-13  22.05  22.15  20.96  21.09  21.09     2.06059e7   
2017-03-14  20.9   20.98  20.15  20.58  20.58     2.00332e7   
⋮
2017-05-17  20.56  20.59  19.69  19.9   19.9      2.92545e7   
2017-05-18  19.86  20.58  19.86  20.27  20.27     1.6005e7    
2017-05-19  20.42  20.64  19.93  20.0   20.0      1.89607e7   
2017-05-22  20.14  20.34  20.01  20.08  20.08     9.1519e6    
2017-05-23  20.14  20.3   19.9   20.03  20.03     8.2392e6    
2017-05-24  20.2   20.62  20.0   20.53  20.53     1.36599e7   
2017-05-25  20.16  21.94  20.11  21.93  21.93     2.4326e7    
2017-05-26  21.66  21.7   21.07  21.22  21.22     1.3374e7    
2017-05-30  21.3   21.58  21.01  21.45  21.45     9.4956e6 

# Get all stock splits in IBM's entire trading history
IBM_splits = yahoo("IBM", event="split")
7x1 Temporal.TS{Float64,Date}: 1964-05-18 to 1999-05-27
Index       StockSplits  
1964-05-18  0.8          
1966-05-18  0.6667       
1968-04-23  0.5          
1973-05-29  0.8          
1979-06-01  0.25         
1997-05-28  0.5          
1999-05-27  0.5 

# Get all divident payments Exxon disbursed during the 2000's
XOM_dividends = yahoo("XOM", event="div", from="2000-01-01", thru="2009-12-31")
41x1 Temporal.TS{Float64,Date}: 2000-02-09 to 2009-11-09
Index       Dividends  
2000-02-09  0.22       
2000-05-11  0.22       
2000-08-10  0.22       
2000-11-09  0.22       
2001-02-07  0.22       
2001-05-10  0.22       
2001-06-18  0.01       
2001-08-09  0.23       
⋮
2007-11-07  0.35       
2008-02-07  0.35       
2008-05-09  0.4        
2008-08-11  0.4        
2008-11-07  0.4        
2009-02-06  0.4        
2009-05-11  0.42       
2009-08-11  0.42       
2009-11-09  0.42 
```

### Google Finance Downloads
```julia
# Let's see how Apple's stock navigated through the financial crisis
Apple = google("AAPL", from="2006-01-01", thru="2010-01-01")
1007x5 Temporal.TS{Float64,Date}: 2006-01-03 to 2009-12-31
Index       Open   High   Low    Close  Volume        
2006-01-03  10.34  10.68  10.32  10.68  2.01853036e8  
2006-01-04  10.73  10.85  10.64  10.71  1.55225609e8  
2006-01-05  10.69  10.7   10.54  10.63  1.12396081e8  
2006-01-06  10.75  10.96  10.65  10.9   1.76139334e8  
2006-01-09  10.96  11.03  10.82  10.86  1.68861224e8  
2006-01-10  10.89  11.7   10.83  11.55  5.70088246e8  
2006-01-11  11.98  12.11  11.8   11.99  3.73548882e8  
2006-01-12  12.14  12.34  11.95  12.04  3.20201966e8  
⋮
2009-12-18  27.6   27.93  27.51  27.92  1.52192516e8  
2009-12-21  28.01  28.54  27.95  28.32  1.53093108e8  
2009-12-22  28.49  28.69  28.38  28.62  8.7378543e7   
2009-12-23  28.75  28.91  28.69  28.87  8.6380987e7   
2009-12-24  29.08  29.91  29.05  29.86  1.25221985e8  
2009-12-28  30.25  30.56  29.94  30.23  1.6114105e8   
2009-12-29  30.38  30.39  29.82  29.87  1.11301071e8  
2009-12-30  29.83  30.29  29.76  30.23  1.03020708e8  
2009-12-31  30.45  30.48  30.08  30.1   8.8102679e7  
```

### Flat File Import
There are some sample data CSV files located in the Temporal package directory with some historical commodities prices for sample use (below file containing corn prices sourced from Quandl using the same "CHRIS" database).
```julia
julia> datafile = "$(Pkg.dir("Temporal"))/data/corn.csv";

julia> corn = tsread(datafile)
14396x8 Temporal.TS{Float64,Date}: 1959-07-01 to 2016-08-30
Index       Open    High    Low     Last    Change  Settle  Volume    OpenInterest  
1959-07-01  120.2   120.3   119.6   119.7   NaN     119.7   3952.0    13997.0       
1959-07-02  119.6   120.0   119.2   119.6   NaN     119.6   2223.0    14047.0       
1959-07-06  119.4   119.5   117.7   118.0   NaN     118.0   3121.0    14206.0       
1959-07-07  118.1   118.5   118.0   118.3   NaN     118.3   3540.0    14142.0       
1959-07-08  118.4   118.5   117.3   117.3   NaN     117.3   2922.0    14353.0       
1959-07-09  117.2   118.3   116.6   118.2   NaN     118.2   3479.0    15051.0       
1959-07-10  118.6   119.4   118.4   119.0   NaN     119.0   3420.0    15370.0       
1959-07-13  118.3   118.4   117.6   118.1   NaN     118.1   3451.0    15846.0       
⋮
2016-08-18  330.0   333.0   326.5   331.75  1.75    332.0   62512.0   233785.0      
2016-08-19  332.25  334.75  330.0   332.5   2.25    334.25  75930.0   225745.0      
2016-08-22  333.75  334.5   330.5   332.5   1.0     333.25  58854.0   202615.0      
2016-08-23  333.0   333.0   326.5   328.25  4.75    328.5   62240.0   189291.0      
2016-08-24  328.25  330.5   325.5   327.0   1.0     327.5   59855.0   178092.0      
2016-08-25  327.0   328.5   322.25  323.0   4.0     323.5   73826.0   163255.0      
2016-08-26  323.5   325.25  315.75  316.0   7.25    316.25  73781.0   144554.0      
2016-08-29  316.25  318.75  310.75  312.0   4.5     311.75  111379.0  94676.0       
2016-08-30  311.75  312.75  303.5   304.0   7.75    304.0   123102.0  66033.0 
```

## Indexing Functionality
Easily one of the more important parts of handling time series data is the ability to retrieve from that time series specific portions of the data that you want. To this end, `TS` objects provide a fairly flexible indexing interface to make it easier to slice & dice data in the ways commonly desired, while maintaining an emphasis on speed and performance wherever possible.

```julia

# First let's get some data in memory to work with
julia> using Temporal

# Download crude oil prices from Quandl
julia> crude = quandl("CHRIS/CME_CL1", from="2010-06-09", thru=string(Dates.today()), freq='d')
1758x8 Temporal.TS{Float64,Date}: 2010-06-09 to 2017-05-30
Index       Open   High   Low    Last   Change  Settle  Volume      PreviousDayOpenInterest  
2010-06-09  72.51  74.96  72.03  74.38  NaN     74.38   436981.0    235520.0                 
2010-06-10  73.87  76.3   73.72  75.48  NaN     75.48   430042.0    198103.0                 
2010-06-11  75.52  75.64  73.26  73.78  NaN     73.78   421739.0    156818.0                 
2010-06-14  74.06  75.99  74.04  75.12  NaN     75.12   321671.0    143248.0                 
2010-06-15  74.77  77.16  74.62  76.94  NaN     76.94   308294.0    132009.0                 
2010-06-16  77.06  78.13  76.06  77.67  NaN     77.67   323357.0    115107.0                 
2010-06-17  77.45  77.79  76.17  76.79  NaN     76.79   303284.0    77148.0                  
2010-06-18  76.55  77.45  75.56  77.18  NaN     77.18   157434.0    51860.0                  
⋮
2017-05-17  48.23  49.5   48.03  48.96  0.41    49.07   633000.0    234981.0                 
2017-05-18  48.93  49.6   48.05  49.34  0.28    49.35   233027.0    113829.0                 
2017-05-19  49.28  50.53  49.28  50.53  0.98    50.33   139324.0    74015.0                  
2017-05-22  50.6   51.06  50.42  50.81  0.4     50.73   21476.0     22887.0                  
2017-05-23  51.04  51.79  50.57  51.49  0.34    51.47   577535.0    631530.0                 
2017-05-24  51.44  51.88  51.03  51.3   0.11    51.36   726312.0    610234.0                 
2017-05-25  51.25  52.0   48.45  48.71  2.46    48.9    1.139346e6  580233.0                 
2017-05-26  48.75  49.94  48.18  49.87  0.9     49.8    759936.0    578141.0                 
2017-05-30  49.93  50.28  49.03  49.65  0.14    49.66   659013.0    576777.0  

# Download Exxon mobile stock prices from Yahoo Finance
julia> exxon = yahoo("XOM", from="2010-01-01")
1864x6 Temporal.TS{Float64,Date}: 2010-01-04 to 2017-05-30
Index       Open   High   Low    Close  AdjClose  Volume     
2010-01-04  68.72  69.26  68.19  69.15  69.15     2.78091e7  
2010-01-05  69.19  69.45  68.8   69.42  69.42     3.01747e7  
2010-01-06  69.45  70.6   69.34  70.02  70.02     3.50447e7  
2010-01-07  69.9   70.06  69.42  69.8   69.8      2.71921e7  
2010-01-08  69.69  69.75  69.22  69.52  69.52     2.48918e7  
2010-01-11  69.94  70.52  69.65  70.3   70.3      3.0685e7   
2010-01-12  69.72  69.99  69.52  69.95  69.95     3.14967e7  
2010-01-13  69.96  70.04  69.26  69.67  69.67     2.48844e7  
⋮
2017-05-17  82.55  83.04  81.96  81.99  81.99     1.11511e7  
2017-05-18  81.77  82.15  81.42  81.75  81.75     9.9058e6   
2017-05-19  82.0   82.09  81.69  81.93  81.93     1.30285e7  
2017-05-22  82.11  82.33  81.93  82.29  82.29     9.2187e6   
2017-05-23  82.32  82.89  82.24  82.58  82.58     6.8572e6   
2017-05-24  82.42  82.54  82.01  82.29  82.29     8.136e6    
2017-05-25  82.33  82.71  81.52  81.75  81.75     1.23709e7  
2017-05-26  81.61  81.8   80.83  81.55  81.55     8.2271e6   
2017-05-30  81.28  81.34  81.04  81.1   81.1      8.7773e6   
```

### Numerical & range-based indexing
```julia
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
```

### String-based date indexing
One of the features of R's xts package that I personally find most appealing is the ease with which one can subset out dates simply by passing easily readable character strings. `Temporal` implements this same logic for `TS` objects.

On a tangential note, it's interesting to observe that while this indexing logic is implemented in low-level `C` code in other packages, this logic has been implemented in pure julia, making it far easier to read, interpret, understand, debug, and/or adapt to one's own purposes.


```julia
julia> crude["2016"]
252x8 Temporal.TS{Float64,Date}: 2016-01-04 to 2016-12-30
Index       Open   High   Low    Last   Change  Settle  Volume    PreviousDayOpenInterest  
2016-01-04  37.6   38.39  36.33  36.88  0.28    36.76   426831.0  437108.0                 
2016-01-05  36.9   37.1   35.74  36.14  0.79    35.97   408389.0  437506.0                 
2016-01-06  36.18  36.39  33.77  34.06  2.0     33.97   528347.0  436383.0                 
2016-01-07  34.09  34.26  32.1   33.26  0.7     33.27   590277.0  431502.0                 
2016-01-08  33.3   34.34  32.64  32.88  0.11    33.16   567056.0  404315.0                 
2016-01-11  32.94  33.2   30.88  31.13  1.75    31.41   619080.0  337703.0                 
2016-01-12  30.44  32.21  29.93  30.58  0.97    30.44   620051.0  283331.0                 
2016-01-13  30.48  31.71  30.1   30.56  0.04    30.48   623300.0  237424.0                 
⋮
2016-12-19  52.15  52.52  51.51  52.12  0.22    52.12   118085.0  70019.0                  
2016-12-20  52.11  52.7   51.84  52.22  0.11    52.23   17494.0   20967.0                  
2016-12-21  53.56  53.79  52.32  52.51  0.81    52.49   466692.0  479955.0                 
2016-12-22  52.52  53.19  52.08  52.65  0.46    52.95   390212.0  471832.0                 
2016-12-23  52.68  53.28  52.26  53.25  0.07    53.02   278830.0  472794.0                 
2016-12-27  53.29  54.1   53.03  53.89  0.88    53.9    273372.0  458071.0                 
2016-12-28  53.93  54.37  53.56  53.66  0.16    54.06   320087.0  459982.0                 
2016-12-29  53.66  54.21  53.46  53.85  0.29    53.77   356339.0  458989.0                 
2016-12-30  53.87  54.09  53.41  53.89  0.05    53.72   266762.0  457983.0    

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
```


### Column/field indexing using Symbols
The `fields` member of the `Temporal.TS` object (wherein the column names are stored) are represented using julia's builtin `Symbol` datatype.

```julia
julia> crude.fields
8-element Array{Symbol,1}:
 :Open                   
 :High                   
 :Low                    
 :Last                   
 :Change                 
 :Settle                 
 :Volume                 
 :PreviousDayOpenInterest

# While we're at it, note you can access the object's
# date/time index Vector using `{object}.index` and
# the raw values Matrix using `{object}.values`
julia> crude.index
1758-element Array{Date,1}:
 2010-06-09
 2010-06-10
 2010-06-11
 2010-06-14
 2010-06-15
 2010-06-16
 2010-06-17
 2010-06-18
 2010-06-21
 ⋮         
 2017-05-18
 2017-05-19
 2017-05-22
 2017-05-23
 2017-05-24
 2017-05-25
 2017-05-26
 2017-05-30

julia> crude.values
1758×8 Array{Float64,2}:
 72.51  74.96  72.03  74.38  NaN     74.38  436981.0        235520.0
 73.87  76.3   73.72  75.48  NaN     75.48  430042.0        198103.0
 75.52  75.64  73.26  73.78  NaN     73.78  421739.0        156818.0
 74.06  75.99  74.04  75.12  NaN     75.12  321671.0        143248.0
 74.77  77.16  74.62  76.94  NaN     76.94  308294.0        132009.0
 77.06  78.13  76.06  77.67  NaN     77.67  323357.0        115107.0
 77.45  77.79  76.17  76.79  NaN     76.79  303284.0         77148.0
 76.55  77.45  75.56  77.18  NaN     77.18  157434.0         51860.0
 77.5   78.92  76.88  77.82  NaN     77.82  124289.0         23357.0
  ⋮                                   ⋮                             
 48.93  49.6   48.05  49.34    0.28  49.35  233027.0        113829.0
 49.28  50.53  49.28  50.53    0.98  50.33  139324.0         74015.0
 50.6   51.06  50.42  50.81    0.4   50.73   21476.0         22887.0
 51.04  51.79  50.57  51.49    0.34  51.47  577535.0        631530.0
 51.44  51.88  51.03  51.3     0.11  51.36  726312.0        610234.0
 51.25  52.0   48.45  48.71    2.46  48.9  1.13935e6        580233.0
 48.75  49.94  48.18  49.87    0.9   49.8   759936.0        578141.0
 49.93  50.28  49.03  49.65    0.14  49.66  659013.0        576777.0


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
