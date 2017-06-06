---
title : Temporal
---

[![Build Status](https://travis-ci.org/dysonance/Temporal.jl.svg?branch=master)](https://travis-ci.org/dysonance/Temporal.jl)

# Temporal
This package provides a flexible & efficient time series class, `TS`, for the [Julia](http://julialang.org/) programming language. While still early in development, the overarching goal is for the class to be able to slice & dice data with the rapid prototyping speed of [R](https://www.r-project.org/)'s [`xts`](https://github.com/joshuaulrich/xts) and [Python](https://www.python.org/)'s [`pandas`](http://pandas.pydata.org/) packages, while retaining the performance one expects from Julia.

# Installation
`Temporal` can be easily installed using Julia's built-in package manager.

````julia

Pkg.add("Temporal")
````




It can then be loaded as usual in Julia.

````julia
julia> using Temporal

````





# Examples

## Data Input/Output
There are currently several options for how to get time series data into the Julia environment as `Temporal.TS` objects.
- Data Vendor Downloads
    - Quandl
    - Yahoo! Finance
    - Google Finance
- Local Flat Files (CSV, TSV, etc.)


### Quandl Data Downloads
````julia
julia> Crude = quandl("CHRIS/CME_CL1", from="2010-06-09", thru=string(Dates.today()), freq='w')  # Download weekly WTI crude oil price data
366x8 Temporal.TS{Float64,Date}: 2010-06-13 to 2017-06-11
Index       Open   High   Low    Last   Change  Settle  Volume     PreviousDayOpenInterest  
2010-06-13  75.52  75.64  73.26  73.78  NaN     73.78   421739.0   156818.0                 
2010-06-20  76.55  77.45  75.56  77.18  NaN     77.18   157434.0   51860.0                  
2010-06-27  76.56  79.19  75.9   78.86  NaN     78.86   316456.0   309630.0                 
2010-07-04  72.67  73.38  71.62  72.14  NaN     72.14   256171.0   300301.0                 
2010-07-11  75.85  76.48  75.0   76.09  NaN     76.09   269887.0   233075.0                 
2010-07-18  76.82  77.15  75.25  76.01  NaN     76.01   225250.0   59046.0                  
2010-07-25  79.27  79.6   78.4   78.98  NaN     78.98   259741.0   364806.0                 
2010-08-01  78.25  79.05  76.83  78.95  NaN     78.95   294425.0   338723.0                 
2010-08-08  82.12  82.67  80.04  80.7   NaN     80.7    397532.0   280208.0                 
⋮
2017-04-09  51.7   52.94  51.49  52.29  0.54    52.24   767404.0   482370.0                 
2017-04-16  52.85  53.39  52.82  52.91  0.07    53.18   468463.0   211355.0                 
2017-04-23  50.71  50.93  49.2   49.63  1.09    49.62   679261.0   620206.0                 
2017-04-30  49.27  49.76  48.8   49.19  0.36    49.33   629561.0   591781.0                 
2017-05-07  45.51  46.68  43.76  46.47  0.7     46.22   1.01503e6  577422.0                 
2017-05-14  47.81  48.07  47.35  47.82  0.01    47.84   527587.0   338671.0                 
2017-05-21  49.28  50.53  49.28  50.53  0.98    50.33   139324.0   74015.0                  
2017-05-28  48.75  49.94  48.18  49.87  0.9     49.8    759936.0   578141.0                 
2017-06-04  48.04  48.19  46.74  47.74  0.7     47.66   798917.0   551317.0                 
2017-06-11  47.71  48.42  46.86  47.39  0.26    47.4    700903.0   545587.0                 

````





### Yahoo! Finance Downloads
````julia
julia> Snapchat = yahoo("SNAP", from="2017-03-03")  # Download historical prices for Snapchat since its IPO date
64x6 Temporal.TS{Float64,Date}: 2017-03-03 to 2017-06-02
Index       Open   High   Low     Close  AdjClose  Volume      
2017-03-03  26.39  29.44  26.06   27.09  27.09     1.481664e8  
2017-03-06  28.17  28.25  23.77   23.77  23.77     7.2903e7    
2017-03-07  22.21  22.5   20.64   21.44  21.44     7.18578e7   
2017-03-08  22.03  23.43  21.31   22.81  22.81     4.98191e7   
2017-03-09  23.17  23.68  22.51   22.71  22.71     2.58032e7   
2017-03-10  23.36  23.4   22.0    22.07  22.07     1.83376e7   
2017-03-13  22.05  22.15  20.96   21.09  21.09     2.06059e7   
2017-03-14  20.9   20.98  20.15   20.58  20.58     2.00332e7   
2017-03-15  20.08  21.4   20.05   20.77  20.77     2.49859e7   
⋮
2017-05-19  20.42  20.64  19.93   20.0   20.0      1.89607e7   
2017-05-22  20.14  20.34  20.01   20.08  20.08     9.1519e6    
2017-05-23  20.14  20.3   19.9    20.03  20.03     8.2392e6    
2017-05-24  20.2   20.62  20.0    20.53  20.53     1.36599e7   
2017-05-25  20.16  21.94  20.11   21.93  21.93     2.4326e7    
2017-05-26  21.66  21.7   21.07   21.22  21.22     1.3374e7    
2017-05-30  21.3   21.58  21.01   21.45  21.45     9.5094e6    
2017-05-31  21.5   21.75  21.094  21.21  21.21     9.5072e6    
2017-06-01  21.32  21.45  21.19   21.34  21.34     7.1465e6    
2017-06-02  21.34  21.45  21.0    21.09  21.09     9.5954e6    

julia> IBM_splits = yahoo("IBM", event="split")  # Get all stock splits in IBM's entire trading history
7x1 Temporal.TS{Float64,Date}: 1964-05-18 to 1999-05-27
Index       StockSplits  
1964-05-18  0.8          
1966-05-18  0.6667       
1968-04-23  0.5          
1973-05-29  0.8          
1979-06-01  0.25         
1997-05-28  0.5          
1999-05-27  0.5          

julia> XOM_dividends = yahoo("XOM", event="div", from="2000-01-01", thru="2009-12-31")  # Get all divident payments Exxon disbursed during the 2000's
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
2001-11-07  0.23       
⋮
2007-08-09  0.35       
2007-11-07  0.35       
2008-02-07  0.35       
2008-05-09  0.4        
2008-08-11  0.4        
2008-11-07  0.4        
2009-02-06  0.4        
2009-05-11  0.42       
2009-08-11  0.42       
2009-11-09  0.42       

````





### Google Finance Downloads
````julia
julia> Apple = google("AAPL", from="2006-01-01", thru="2010-01-01")  # Let's see how Apple's stock navigated through the financial crisis
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
2006-01-13  12.14  12.29  12.09  12.23  1.94153393e8  
⋮
2009-12-17  27.75  27.86  27.29  27.41  9.7209056e7   
2009-12-18  27.6   27.93  27.51  27.92  1.52192516e8  
2009-12-21  28.01  28.54  27.95  28.32  1.53093108e8  
2009-12-22  28.49  28.69  28.38  28.62  8.7378543e7   
2009-12-23  28.75  28.91  28.69  28.87  8.6380987e7   
2009-12-24  29.08  29.91  29.05  29.86  1.25221985e8  
2009-12-28  30.25  30.56  29.94  30.23  1.6114105e8   
2009-12-29  30.38  30.39  29.82  29.87  1.11301071e8  
2009-12-30  29.83  30.29  29.76  30.23  1.03020708e8  
2009-12-31  30.45  30.48  30.08  30.1   8.8102679e7   

````





### Flat File Import

There are some sample data CSV files located in the Temporal package directory with some historical commodities prices for sample use (below file containing corn prices sourced from Quandl using the same "CHRIS" database).

````julia
julia> datafile = "$(Pkg.dir("Temporal"))/data/corn.csv"
"/Users/jacobamos/.julia/v0.6/Temporal/data/corn.csv"

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
1959-07-14  118.3   119.7   118.2   119.6   NaN     119.6   1983.0    15535.0       
⋮
2016-08-17  327.25  330.75  327.0   330.25  2.75    330.25  90626.0   242828.0      
2016-08-18  330.0   333.0   326.5   331.75  1.75    332.0   62512.0   233785.0      
2016-08-19  332.25  334.75  330.0   332.5   2.25    334.25  75930.0   225745.0      
2016-08-22  333.75  334.5   330.5   332.5   1.0     333.25  58854.0   202615.0      
2016-08-23  333.0   333.0   326.5   328.25  4.75    328.5   62240.0   189291.0      
2016-08-24  328.25  330.5   325.5   327.0   1.0     327.5   59855.0   178092.0      
2016-08-25  327.0   328.5   322.25  323.0   4.0     323.5   73826.0   163255.0      
2016-08-26  323.5   325.25  315.75  316.0   7.25    316.25  73781.0   144554.0      
2016-08-29  316.25  318.75  310.75  312.0   4.5     311.75  111379.0  94676.0       
2016-08-30  311.75  312.75  303.5   304.0   7.75    304.0   123102.0  66033.0       

````





## Indexing Functionality
Easily one of the more important parts of handling time series data is the ability to retrieve from that time series specific portions of the data that you want. To this end, `TS` objects provide a fairly flexible indexing interface to make it easier to slice & dice data in the ways commonly desired, while maintaining an emphasis on speed and performance wherever possible.

````julia
julia> crude = quandl("CHRIS/CME_CL1")  # Download crude oil prices from Quandl
8588x8 Temporal.TS{Float64,Date}: 1983-03-30 to 2017-06-05
Index       Open   High   Low    Last   Change  Settle  Volume      PreviousDayOpenInterest  
1983-03-30  29.01  29.56  29.01  29.4   NaN     29.4    949.0       470.0                    
1983-03-31  29.4   29.6   29.25  29.29  NaN     29.29   521.0       523.0                    
1983-04-04  29.3   29.7   29.29  29.44  NaN     29.44   156.0       583.0                    
1983-04-05  29.5   29.8   29.5   29.71  NaN     29.71   175.0       623.0                    
1983-04-06  29.9   29.92  29.65  29.9   NaN     29.9    392.0       640.0                    
1983-04-07  29.9   30.2   29.86  30.17  NaN     30.17   817.0       795.0                    
1983-04-08  30.65  30.65  30.25  30.38  NaN     30.38   365.0       651.0                    
1983-04-11  30.4   30.41  30.0   30.26  NaN     30.26   265.0       681.0                    
1983-04-12  30.5   31.0   30.5   30.83  NaN     30.83   469.0       711.0                    
⋮
2017-05-22  50.6   51.06  50.42  50.81  0.4     50.73   21476.0     22887.0                  
2017-05-23  51.04  51.79  50.57  51.49  0.34    51.47   577535.0    631530.0                 
2017-05-24  51.44  51.88  51.03  51.3   0.11    51.36   726312.0    610234.0                 
2017-05-25  51.25  52.0   48.45  48.71  2.46    48.9    1.139346e6  580233.0                 
2017-05-26  48.75  49.94  48.18  49.87  0.9     49.8    759936.0    578141.0                 
2017-05-30  49.93  50.28  49.03  49.65  0.14    49.66   659013.0    576777.0                 
2017-05-31  49.65  49.71  47.73  48.63  1.34    48.32   769567.0    569166.0                 
2017-06-01  48.63  49.17  47.9   48.03  0.04    48.36   770895.0    560137.0                 
2017-06-02  48.04  48.19  46.74  47.74  0.7     47.66   798917.0    551317.0                 
2017-06-05  47.71  48.42  46.86  47.39  0.26    47.4    700903.0    545587.0                 

````





### Numerical & range-based indexing
````julia
julia> crude[1]  # get the first row
1x8 Temporal.TS{Float64,Date}: 1983-03-30 to 1983-03-30
Index       Open   High   Low    Last  Change  Settle  Volume  PreviousDayOpenInterest  
1983-03-30  29.01  29.56  29.01  29.4  NaN     29.4    949.0   470.0                    

julia> crude[end,:]  # get the last row
1x8 Temporal.TS{Float64,Date}: 2017-06-05 to 2017-06-05
Index       Open   High   Low    Last   Change  Settle  Volume    PreviousDayOpenInterest  
2017-06-05  47.71  48.42  46.86  47.39  0.26    47.4    700903.0  545587.0                 

julia> crude[end-100:end, 1:4]
101x4 Temporal.TS{Float64,Date}: 2017-01-10 to 2017-06-05
Index       Open   High   Low    Last   
2017-01-10  51.83  52.37  50.71  50.78  
2017-01-11  50.81  52.78  50.75  52.37  
2017-01-12  52.37  53.5   52.12  53.03  
2017-01-13  53.05  53.17  52.27  52.52  
2017-01-17  52.55  53.52  52.12  52.53  
2017-01-18  52.52  52.79  50.91  51.39  
2017-01-19  51.39  51.87  51.02  51.41  
2017-01-20  51.45  52.9   51.39  52.33  
2017-01-23  53.33  53.47  52.21  52.83  
⋮
2017-05-22  50.6   51.06  50.42  50.81  
2017-05-23  51.04  51.79  50.57  51.49  
2017-05-24  51.44  51.88  51.03  51.3   
2017-05-25  51.25  52.0   48.45  48.71  
2017-05-26  48.75  49.94  48.18  49.87  
2017-05-30  49.93  50.28  49.03  49.65  
2017-05-31  49.65  49.71  47.73  48.63  
2017-06-01  48.63  49.17  47.9   48.03  
2017-06-02  48.04  48.19  46.74  47.74  
2017-06-05  47.71  48.42  46.86  47.39  

````





### Column/field indexing using Symbols
The `fields` member of the `Temporal.TS` object (wherein the column names are stored) are represented using julia's builtin `Symbol` datatype.

````julia
julia> crude[:Settle]
8588x1 Temporal.TS{Float64,Date}: 1983-03-30 to 2017-06-05
Index       Settle  
1983-03-30  29.4    
1983-03-31  29.29   
1983-04-04  29.44   
1983-04-05  29.71   
1983-04-06  29.9    
1983-04-07  30.17   
1983-04-08  30.38   
1983-04-11  30.26   
1983-04-12  30.83   
⋮
2017-05-22  50.73   
2017-05-23  51.47   
2017-05-24  51.36   
2017-05-25  48.9    
2017-05-26  49.8    
2017-05-30  49.66   
2017-05-31  48.32   
2017-06-01  48.36   
2017-06-02  47.66   
2017-06-05  47.4    

julia> crude[[:Settle,:Volume]]
8588x2 Temporal.TS{Float64,Date}: 1983-03-30 to 2017-06-05
Index       Settle  Volume      
1983-03-30  29.4    949.0       
1983-03-31  29.29   521.0       
1983-04-04  29.44   156.0       
1983-04-05  29.71   175.0       
1983-04-06  29.9    392.0       
1983-04-07  30.17   817.0       
1983-04-08  30.38   365.0       
1983-04-11  30.26   265.0       
1983-04-12  30.83   469.0       
⋮
2017-05-22  50.73   21476.0     
2017-05-23  51.47   577535.0    
2017-05-24  51.36   726312.0    
2017-05-25  48.9    1.139346e6  
2017-05-26  49.8    759936.0    
2017-05-30  49.66   659013.0    
2017-05-31  48.32   769567.0    
2017-06-01  48.36   770895.0    
2017-06-02  47.66   798917.0    
2017-06-05  47.4    700903.0    

````





### Date indexing to select rows

````julia
julia> using Base.Dates

julia> crude[today()]  # select the row corresponding to today's date
1x8 Temporal.TS{Float64,Date}: 2017-06-05 to 2017-06-05
Index       Open   High   Low    Last   Change  Settle  Volume    PreviousDayOpenInterest  
2017-06-05  47.71  48.42  46.86  47.39  0.26    47.4    700903.0  545587.0                 

julia> crude[collect(today()-Year(1):Day(1):today())]
252x8 Temporal.TS{Float64,Date}: 2016-06-06 to 2017-06-05
Index       Open   High   Low    Last   Change  Settle  Volume      PreviousDayOpenInterest  
2016-06-06  48.88  49.9   48.71  49.71  1.07    49.69   444831.0    499269.0                 
2016-06-07  49.71  50.53  49.44  50.43  0.67    50.36   518454.0    499645.0                 
2016-06-08  50.41  51.62  50.32  51.53  0.87    51.23   633335.0    444584.0                 
2016-06-09  51.45  51.67  50.23  50.46  0.67    50.56   539403.0    374159.0                 
2016-06-10  50.47  50.73  48.8   48.87  1.49    49.07   572085.0    308749.0                 
2016-06-13  48.85  49.28  48.16  48.56  0.19    48.88   498657.0    257331.0                 
2016-06-14  48.52  48.69  47.84  47.9   0.39    48.49   446254.0    238975.0                 
2016-06-15  47.9   48.72  47.28  47.49  0.48    48.01   518669.0    182099.0                 
2016-06-16  47.45  47.75  45.91  45.99  1.8     46.21   495357.0    147544.0                 
⋮
2017-05-22  50.6   51.06  50.42  50.81  0.4     50.73   21476.0     22887.0                  
2017-05-23  51.04  51.79  50.57  51.49  0.34    51.47   577535.0    631530.0                 
2017-05-24  51.44  51.88  51.03  51.3   0.11    51.36   726312.0    610234.0                 
2017-05-25  51.25  52.0   48.45  48.71  2.46    48.9    1.139346e6  580233.0                 
2017-05-26  48.75  49.94  48.18  49.87  0.9     49.8    759936.0    578141.0                 
2017-05-30  49.93  50.28  49.03  49.65  0.14    49.66   659013.0    576777.0                 
2017-05-31  49.65  49.71  47.73  48.63  1.34    48.32   769567.0    569166.0                 
2017-06-01  48.63  49.17  47.9   48.03  0.04    48.36   770895.0    560137.0                 
2017-06-02  48.04  48.19  46.74  47.74  0.7     47.66   798917.0    551317.0                 
2017-06-05  47.71  48.42  46.86  47.39  0.26    47.4    700903.0    545587.0                 

````





### String-based date indexing
One of the features of R's xts package that I personally find most appealing is the ease with which one can subset out dates simply by passing easily readable character strings. `Temporal` implements this same logic for `TS` objects.

On a tangential note, it's interesting to observe that while this indexing logic is implemented in low-level `C` code in other packages, this logic has been implemented in pure julia, making it far easier to read, interpret, understand, debug, and/or adapt to one's own purposes.

````julia
julia> crude["2016"]  # retrieve all rows from the year 2016
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
2016-01-14  30.6   31.77  30.28  31.21  0.72    31.2    524010.0  176000.0                 
⋮
2016-12-16  51.1   52.08  50.5   52.03  1.0     51.9    247448.0  109432.0                 
2016-12-19  52.15  52.52  51.51  52.12  0.22    52.12   118085.0  70019.0                  
2016-12-20  52.11  52.7   51.84  52.22  0.11    52.23   17494.0   20967.0                  
2016-12-21  53.56  53.79  52.32  52.51  0.81    52.49   466692.0  479955.0                 
2016-12-22  52.52  53.19  52.08  52.65  0.46    52.95   390212.0  471832.0                 
2016-12-23  52.68  53.28  52.26  53.25  0.07    53.02   278830.0  472794.0                 
2016-12-27  53.29  54.1   53.03  53.89  0.88    53.9    273372.0  458071.0                 
2016-12-28  53.93  54.37  53.56  53.66  0.16    54.06   320087.0  459982.0                 
2016-12-29  53.66  54.21  53.46  53.85  0.29    53.77   356339.0  458989.0                 
2016-12-30  53.87  54.09  53.41  53.89  0.05    53.72   266762.0  457983.0                 

julia> crude["2015", 6]  # retrive the sixth column from 2015
252x1 Temporal.TS{Float64,Date}: 2015-01-02 to 2015-12-31
Index       Settle  
2015-01-02  52.69   
2015-01-05  50.04   
2015-01-06  47.93   
2015-01-07  48.65   
2015-01-08  48.79   
2015-01-09  48.36   
2015-01-12  46.07   
2015-01-13  45.89   
2015-01-14  48.48   
⋮
2015-12-17  34.95   
2015-12-18  34.73   
2015-12-21  34.74   
2015-12-22  36.14   
2015-12-23  37.5    
2015-12-24  38.1    
2015-12-28  36.81   
2015-12-29  37.87   
2015-12-30  36.6    
2015-12-31  37.04   

julia> crude["/2012", 1:4]  # retrieve first four columns for all rows through 2012
7475x4 Temporal.TS{Float64,Date}: 1983-03-30 to 2012-12-31
Index       Open   High   Low    Last   
1983-03-30  29.01  29.56  29.01  29.4   
1983-03-31  29.4   29.6   29.25  29.29  
1983-04-04  29.3   29.7   29.29  29.44  
1983-04-05  29.5   29.8   29.5   29.71  
1983-04-06  29.9   29.92  29.65  29.9   
1983-04-07  29.9   30.2   29.86  30.17  
1983-04-08  30.65  30.65  30.25  30.38  
1983-04-11  30.4   30.41  30.0   30.26  
1983-04-12  30.5   31.0   30.5   30.83  
⋮
2012-12-17  86.88  87.71  86.48  87.2   
2012-12-18  87.45  88.16  87.21  87.93  
2012-12-19  87.94  89.9   87.81  89.51  
2012-12-20  89.69  90.54  89.26  90.13  
2012-12-21  90.02  90.07  87.96  88.66  
2012-12-24  88.6   88.86  88.2   88.61  
2012-12-26  88.62  91.3   88.59  90.98  
2012-12-27  91.0   91.44  90.05  90.87  
2012-12-28  91.15  91.49  90.32  90.8   
2012-12-31  90.41  91.99  90.0   91.82  

julia> crude["2010/", end-2:end]  # retrieve last three columns for the year 2010 and on
1870x3 Temporal.TS{Float64,Date}: 2010-01-04 to 2017-06-05
Index       Settle  Volume      PreviousDayOpenInterest  
2010-01-04  81.51   263542.0    290352.0                 
2010-01-05  81.77   258887.0    280580.0                 
2010-01-06  83.18   370059.0    275043.0                 
2010-01-07  82.66   246632.0    262309.0                 
2010-01-08  82.75   310377.0    250371.0                 
2010-01-11  82.52   296304.0    226210.0                 
2010-01-12  80.79   333866.0    189671.0                 
2010-01-13  79.65   401627.0    140073.0                 
2010-01-14  79.39   401627.0    140073.0                 
⋮
2017-05-22  50.73   21476.0     22887.0                  
2017-05-23  51.47   577535.0    631530.0                 
2017-05-24  51.36   726312.0    610234.0                 
2017-05-25  48.9    1.139346e6  580233.0                 
2017-05-26  49.8    759936.0    578141.0                 
2017-05-30  49.66   659013.0    576777.0                 
2017-05-31  48.32   769567.0    569166.0                 
2017-06-01  48.36   770895.0    560137.0                 
2017-06-02  47.66   798917.0    551317.0                 
2017-06-05  47.4    700903.0    545587.0                 

julia> crude["2014/2015", :Settle]  # retrieve settle prices for the years 2014 and 2015
504x1 Temporal.TS{Float64,Date}: 2014-01-02 to 2015-12-31
Index       Settle  
2014-01-02  95.44   
2014-01-03  93.96   
2014-01-06  93.43   
2014-01-07  93.67   
2014-01-08  92.33   
2014-01-09  91.66   
2014-01-10  92.72   
2014-01-13  91.8    
2014-01-14  92.59   
⋮
2015-12-17  34.95   
2015-12-18  34.73   
2015-12-21  34.74   
2015-12-22  36.14   
2015-12-23  37.5    
2015-12-24  38.1    
2015-12-28  36.81   
2015-12-29  37.87   
2015-12-30  36.6    
2015-12-31  37.04   

````





## Merging, joining, and combining data
````julia
julia> gasoline = quandl("CHRIS/CME_RB1")
2929x8 Temporal.TS{Float64,Date}: 2005-10-03 to 2017-06-05
Index       Open    High    Low     Last    Change  Settle  Volume   PreviousDayOpenInterest  
2005-10-03  1.995   2.0     1.94    1.9488  NaN     1.9488  2774.0   14940.0                  
2005-10-04  1.91    1.9203  1.87    1.9203  NaN     1.9203  2533.0   15287.0                  
2005-10-05  1.928   1.93    1.832   1.8361  NaN     1.8361  3474.0   15297.0                  
2005-10-06  1.795   1.795   1.76    1.7867  NaN     1.7867  4675.0   15554.0                  
2005-10-07  1.79    1.8076  1.77    1.8076  NaN     1.8076  6554.0   15634.0                  
2005-10-10  1.78    1.7975  1.77    1.7971  NaN     1.7971  4434.0   15960.0                  
2005-10-11  1.8225  1.838   1.805   1.838   NaN     1.838   5185.0   17434.0                  
2005-10-12  1.83    1.85    1.825   1.8407  NaN     1.8407  4747.0   18082.0                  
2005-10-13  1.8075  1.83    1.77    1.7936  NaN     1.7936  4914.0   19110.0                  
⋮
2017-05-22  1.6549  1.6679  1.6487  1.6588  0.0103  1.6626  25588.0  51897.0                  
2017-05-23  1.6629  1.6691  1.6434  1.6652  0.0012  1.6614  33341.0  47856.0                  
2017-05-24  1.6685  1.675   1.641   1.654   0.0088  1.6526  31630.0  38881.0                  
2017-05-25  1.6548  1.6695  1.5973  1.6087  0.0433  1.6093  31633.0  29253.0                  
2017-05-26  1.6105  1.6479  1.6003  1.6477  0.0333  1.6426  34316.0  24010.0                  
2017-05-30  1.6416  1.66    1.6226  1.6357  0.0037  1.6389  23101.0  15638.0                  
2017-05-31  1.64    1.6402  1.589   1.6127  0.0267  1.6122  5390.0   5461.0                   
2017-06-01  1.6051  1.6225  1.5885  1.5897  0.0049  1.6014  73561.0  140097.0                 
2017-06-02  1.5921  1.596   1.5545  1.5732  0.0243  1.5771  63191.0  137962.0                 
2017-06-05  1.577   1.5905  1.5357  1.5388  0.039   1.5381  67039.0  138006.0                 

julia> gasoline_settles = cl(gasoline)  # (note `cl` function will take fields named :Close, :AdjClose, :Settle, and :Last)
2929x1 Temporal.TS{Float64,Date}: 2005-10-03 to 2017-06-05
Index       Settle  
2005-10-03  1.9488  
2005-10-04  1.9203  
2005-10-05  1.8361  
2005-10-06  1.7867  
2005-10-07  1.8076  
2005-10-10  1.7971  
2005-10-11  1.838   
2005-10-12  1.8407  
2005-10-13  1.7936  
⋮
2017-05-22  1.6626  
2017-05-23  1.6614  
2017-05-24  1.6526  
2017-05-25  1.6093  
2017-05-26  1.6426  
2017-05-30  1.6389  
2017-05-31  1.6122  
2017-06-01  1.6014  
2017-06-02  1.5771  
2017-06-05  1.5381  

julia> crude_settles = cl(crude)  # all OHLC(V) functions also implemented: op, hi, lo, cl, vo
8588x1 Temporal.TS{Float64,Date}: 1983-03-30 to 2017-06-05
Index       Settle  
1983-03-30  29.4    
1983-03-31  29.29   
1983-04-04  29.44   
1983-04-05  29.71   
1983-04-06  29.9    
1983-04-07  30.17   
1983-04-08  30.38   
1983-04-11  30.26   
1983-04-12  30.83   
⋮
2017-05-22  50.73   
2017-05-23  51.47   
2017-05-24  51.36   
2017-05-25  48.9    
2017-05-26  49.8    
2017-05-30  49.66   
2017-05-31  48.32   
2017-06-01  48.36   
2017-06-02  47.66   
2017-06-05  47.4    

julia> 
crude_settles.fields[1] = :Crude;

julia> gasoline_settles.fields[1] = :Gasoline;

julia> 
A = ojoin(crude_settles, gasoline_settles)  # full outer join
8589x2 Temporal.TS{Float64,Date}: 1983-03-30 to 2017-06-05
Index       Crude  Gasoline  
1983-03-30  29.4   NaN       
1983-03-31  29.29  NaN       
1983-04-04  29.44  NaN       
1983-04-05  29.71  NaN       
1983-04-06  29.9   NaN       
1983-04-07  30.17  NaN       
1983-04-08  30.38  NaN       
1983-04-11  30.26  NaN       
1983-04-12  30.83  NaN       
⋮
2017-05-22  50.73  1.6626    
2017-05-23  51.47  1.6614    
2017-05-24  51.36  1.6526    
2017-05-25  48.9   1.6093    
2017-05-26  49.8   1.6426    
2017-05-30  49.66  1.6389    
2017-05-31  48.32  1.6122    
2017-06-01  48.36  1.6014    
2017-06-02  47.66  1.5771    
2017-06-05  47.4   1.5381    

julia> A = [crude_settles gasoline_settles]  # hcat -- same as full outer join
8589x2 Temporal.TS{Float64,Date}: 1983-03-30 to 2017-06-05
Index       Crude  Gasoline  
1983-03-30  29.4   NaN       
1983-03-31  29.29  NaN       
1983-04-04  29.44  NaN       
1983-04-05  29.71  NaN       
1983-04-06  29.9   NaN       
1983-04-07  30.17  NaN       
1983-04-08  30.38  NaN       
1983-04-11  30.26  NaN       
1983-04-12  30.83  NaN       
⋮
2017-05-22  50.73  1.6626    
2017-05-23  51.47  1.6614    
2017-05-24  51.36  1.6526    
2017-05-25  48.9   1.6093    
2017-05-26  49.8   1.6426    
2017-05-30  49.66  1.6389    
2017-05-31  48.32  1.6122    
2017-06-01  48.36  1.6014    
2017-06-02  47.66  1.5771    
2017-06-05  47.4   1.5381    

julia> A = dropnan(A)
2928x2 Temporal.TS{Float64,Date}: 2005-10-03 to 2017-06-05
Index       Crude  Gasoline  
2005-10-03  65.47  1.9488    
2005-10-04  63.9   1.9203    
2005-10-05  62.79  1.8361    
2005-10-06  61.36  1.7867    
2005-10-07  61.84  1.8076    
2005-10-10  61.8   1.7971    
2005-10-11  63.53  1.838     
2005-10-12  64.12  1.8407    
2005-10-13  63.08  1.7936    
⋮
2017-05-22  50.73  1.6626    
2017-05-23  51.47  1.6614    
2017-05-24  51.36  1.6526    
2017-05-25  48.9   1.6093    
2017-05-26  49.8   1.6426    
2017-05-30  49.66  1.6389    
2017-05-31  48.32  1.6122    
2017-06-01  48.36  1.6014    
2017-06-02  47.66  1.5771    
2017-06-05  47.4   1.5381    

julia> 
A = [A randn(size(A,1))]  # can join to arrays of same size
2928x3 Temporal.TS{Float64,Date}: 2005-10-03 to 2017-06-05
Index       Crude  Gasoline   A       
2005-10-03  65.47  1.9488     0.4368  
2005-10-04  63.9   1.9203     1.7658  
2005-10-05  62.79  1.8361     0.7333  
2005-10-06  61.36  1.7867    -1.011   
2005-10-07  61.84  1.8076    -0.8785  
2005-10-10  61.8   1.7971     0.2655  
2005-10-11  63.53  1.838     -1.5922  
2005-10-12  64.12  1.8407    -1.8957  
2005-10-13  63.08  1.7936    -0.1358  
⋮
2017-05-22  50.73  1.6626     1.6572  
2017-05-23  51.47  1.6614    -0.8464  
2017-05-24  51.36  1.6526    -0.4804  
2017-05-25  48.9   1.6093     0.4882  
2017-05-26  49.8   1.6426     2.0581  
2017-05-30  49.66  1.6389    -1.1716  
2017-05-31  48.32  1.6122     0.256   
2017-06-01  48.36  1.6014    -0.9201  
2017-06-02  47.66  1.5771     1.6278  
2017-06-05  47.4   1.5381     0.3595  

julia> A = [A 0];  # can join to single numbers as well

julia> A.fields[3:4] = [:RandomNormal, :Zeros];

julia> A
2928x4 Temporal.TS{Float64,Date}: 2005-10-03 to 2017-06-05
Index       Crude  Gasoline   RandomNormal Zeros  
2005-10-03  65.47  1.9488     0.4368       0.0    
2005-10-04  63.9   1.9203     1.7658       0.0    
2005-10-05  62.79  1.8361     0.7333       0.0    
2005-10-06  61.36  1.7867    -1.011        0.0    
2005-10-07  61.84  1.8076    -0.8785       0.0    
2005-10-10  61.8   1.7971     0.2655       0.0    
2005-10-11  63.53  1.838     -1.5922       0.0    
2005-10-12  64.12  1.8407    -1.8957       0.0    
2005-10-13  63.08  1.7936    -0.1358       0.0    
⋮
2017-05-22  50.73  1.6626     1.6572       0.0    
2017-05-23  51.47  1.6614    -0.8464       0.0    
2017-05-24  51.36  1.6526    -0.4804       0.0    
2017-05-25  48.9   1.6093     0.4882       0.0    
2017-05-26  49.8   1.6426     2.0581       0.0    
2017-05-30  49.66  1.6389    -1.1716       0.0    
2017-05-31  48.32  1.6122     0.256        0.0    
2017-06-01  48.36  1.6014    -0.9201       0.0    
2017-06-02  47.66  1.5771     1.6278       0.0    
2017-06-05  47.4   1.5381     0.3595       0.0    

julia> 
ijoin(crude_settles, gasoline_settles)  # inner join -- keep points in time where both objects have observations
2928x2 Temporal.TS{Float64,Date}: 2005-10-03 to 2017-06-05
Index       Crude  Gasoline  
2005-10-03  65.47  1.9488    
2005-10-04  63.9   1.9203    
2005-10-05  62.79  1.8361    
2005-10-06  61.36  1.7867    
2005-10-07  61.84  1.8076    
2005-10-10  61.8   1.7971    
2005-10-11  63.53  1.838     
2005-10-12  64.12  1.8407    
2005-10-13  63.08  1.7936    
⋮
2017-05-22  50.73  1.6626    
2017-05-23  51.47  1.6614    
2017-05-24  51.36  1.6526    
2017-05-25  48.9   1.6093    
2017-05-26  49.8   1.6426    
2017-05-30  49.66  1.6389    
2017-05-31  48.32  1.6122    
2017-06-01  48.36  1.6014    
2017-06-02  47.66  1.5771    
2017-06-05  47.4   1.5381    

julia> ljoin(crude_settles, gasoline_settles)  # left join
8588x2 Temporal.TS{Float64,Date}: 1983-03-30 to 2017-06-05
Index       Crude  Gasoline  
1983-03-30  29.4   NaN       
1983-03-31  29.29  NaN       
1983-04-04  29.44  NaN       
1983-04-05  29.71  NaN       
1983-04-06  29.9   NaN       
1983-04-07  30.17  NaN       
1983-04-08  30.38  NaN       
1983-04-11  30.26  NaN       
1983-04-12  30.83  NaN       
⋮
2017-05-22  50.73  1.6626    
2017-05-23  51.47  1.6614    
2017-05-24  51.36  1.6526    
2017-05-25  48.9   1.6093    
2017-05-26  49.8   1.6426    
2017-05-30  49.66  1.6389    
2017-05-31  48.32  1.6122    
2017-06-01  48.36  1.6014    
2017-06-02  47.66  1.5771    
2017-06-05  47.4   1.5381    

julia> rjoin(crude_settles, gasoline_settles)  # right join
2929x2 Temporal.TS{Float64,Date}: 2005-10-03 to 2017-06-05
Index       Crude  Gasoline  
2005-10-03  65.47  1.9488    
2005-10-04  63.9   1.9203    
2005-10-05  62.79  1.8361    
2005-10-06  61.36  1.7867    
2005-10-07  61.84  1.8076    
2005-10-10  61.8   1.7971    
2005-10-11  63.53  1.838     
2005-10-12  64.12  1.8407    
2005-10-13  63.08  1.7936    
⋮
2017-05-22  50.73  1.6626    
2017-05-23  51.47  1.6614    
2017-05-24  51.36  1.6526    
2017-05-25  48.9   1.6093    
2017-05-26  49.8   1.6426    
2017-05-30  49.66  1.6389    
2017-05-31  48.32  1.6122    
2017-06-01  48.36  1.6014    
2017-06-02  47.66  1.5771    
2017-06-05  47.4   1.5381    

julia> 
fracker_era = [crude["/2013"]; crude["2016/"]]  # vertical concatenation also implemented!
8084x8 Temporal.TS{Float64,Date}: 1983-03-30 to 2017-06-05
Index       Open   High   Low    Last   Change  Settle  Volume      PreviousDayOpenInterest  
1983-03-30  29.01  29.56  29.01  29.4   NaN     29.4    949.0       470.0                    
1983-03-31  29.4   29.6   29.25  29.29  NaN     29.29   521.0       523.0                    
1983-04-04  29.3   29.7   29.29  29.44  NaN     29.44   156.0       583.0                    
1983-04-05  29.5   29.8   29.5   29.71  NaN     29.71   175.0       623.0                    
1983-04-06  29.9   29.92  29.65  29.9   NaN     29.9    392.0       640.0                    
1983-04-07  29.9   30.2   29.86  30.17  NaN     30.17   817.0       795.0                    
1983-04-08  30.65  30.65  30.25  30.38  NaN     30.38   365.0       651.0                    
1983-04-11  30.4   30.41  30.0   30.26  NaN     30.26   265.0       681.0                    
1983-04-12  30.5   31.0   30.5   30.83  NaN     30.83   469.0       711.0                    
⋮
2017-05-22  50.6   51.06  50.42  50.81  0.4     50.73   21476.0     22887.0                  
2017-05-23  51.04  51.79  50.57  51.49  0.34    51.47   577535.0    631530.0                 
2017-05-24  51.44  51.88  51.03  51.3   0.11    51.36   726312.0    610234.0                 
2017-05-25  51.25  52.0   48.45  48.71  2.46    48.9    1.139346e6  580233.0                 
2017-05-26  48.75  49.94  48.18  49.87  0.9     49.8    759936.0    578141.0                 
2017-05-30  49.93  50.28  49.03  49.65  0.14    49.66   659013.0    576777.0                 
2017-05-31  49.65  49.71  47.73  48.63  1.34    48.32   769567.0    569166.0                 
2017-06-01  48.63  49.17  47.9   48.03  0.04    48.36   770895.0    560137.0                 
2017-06-02  48.04  48.19  46.74  47.74  0.7     47.66   798917.0    551317.0                 
2017-06-05  47.71  48.42  46.86  47.39  0.26    47.4    700903.0    545587.0                 

julia> avg_return_overall = mean(diff(log(cl(crude))))
5.562216773685746e-5

julia> avg_return_fracker = mean(diff(log(cl(fracker_era))))
5.909038158559879e-5

````





## Aggregation/collapsing functionality

````julia

eom(crude)  # Get the last values observed at the end of each month
[crude.index eom(crude.index)]  # (NOTE: the `eom` function returns a Boolean Vector when passed a Vector of TimeTypes)
collapse(crude, eom(crude.index), fun=mean)  # monthly averages for all columns
collapse(crude[:Volume], eoy(crude.index), fun=sum)  # Get the total yearly trading volume of crude oil
````




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
