var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#Temporal.jl-Documentation-1",
    "page": "Home",
    "title": "Temporal.jl Documentation",
    "category": "section",
    "text": "CurrentModule = Temporal"
},

{
    "location": "#Topics-1",
    "page": "Home",
    "title": "Topics",
    "category": "section",
    "text": "Pages = [\"ts.md\", \"operations.md\", \"indexing.md\", \"combining.md\", \"aggregation.md\", \"io.md\", \"utils.md\"]\nDepth = 3"
},

{
    "location": "overview/#",
    "page": "Overview",
    "title": "Overview",
    "category": "page",
    "text": "using Temporal, Dates, Indicators, Plots, Pkg, Random"
},

{
    "location": "overview/#Temporal-1",
    "page": "Overview",
    "title": "Temporal",
    "category": "section",
    "text": "This package provides a flexible & efficient time series class, TS, for the Julia programming language. While still early in development, the overarching goal is for the class to be able to slice & dice data with the rapid prototyping speed of R\'s xts and Python\'s pandas packages, while retaining the performance one expects from Julia."
},

{
    "location": "overview/#Installation-1",
    "page": "Overview",
    "title": "Installation",
    "category": "section",
    "text": "Temporal can be easily installed using Julia\'s built-in package manager.using Pkg\nPkg.add(\"Temporal\")\nusing Temporal"
},

{
    "location": "overview/#Introduction-1",
    "page": "Overview",
    "title": "Introduction",
    "category": "section",
    "text": ""
},

{
    "location": "overview/#The-TS-Type-1",
    "page": "Overview",
    "title": "The TS Type",
    "category": "section",
    "text": ""
},

{
    "location": "overview/#Member-Variables-1",
    "page": "Overview",
    "title": "Member Variables",
    "category": "section",
    "text": "TS objects store three member variables to facilitate data manipulation and analysis.values: an Array of the values of the time series data\nindex: a Vector whose elements are either of type Date or DateTime indexing the values of the time series\nfields: a Vector whose elements are of type Symbol representing the column names of the time series data"
},

{
    "location": "overview/#Constructors-1",
    "page": "Overview",
    "title": "Constructors",
    "category": "section",
    "text": "The TS object type can be created in a number of ways. One thing to note is that when constructing the TS object, passing only the Array of values will automatically create the index and the fields members. When not passed explicitly, the index defaults to a series of dates that ends with today\'s date, and begins N-1 days before (where N is the number of rows of the values). The fields (or column names) are automatically set in a similar fashion as Excel when not given explicitly (A, B, C, ..., X, Y, Z, AA, AB, ...).using Temporal, Dates\nN, K = 100, 4;\nRandom.seed!(1);\nvalues = rand(N, K);\nTS(values)\nindex = today()-Day(N-1):Day(1):today();\nTS(values, index)\nfields = [:A, :B, :C, :D];\nX = TS(values, index, fields)Equivalently, one can construct a TS object using the standard rand construction approach.Random.seed!(1);\nY = rand(TS, (N,K))\nX == Y"
},

{
    "location": "overview/#Operations-1",
    "page": "Overview",
    "title": "Operations",
    "category": "section",
    "text": "The standard operations that apply to Array objects will generally also work for TS objects. (If there is an operation that does not have a method defined for the TS type that you feel is missing, please don\'t hesitate to submit an issue and we will get it added ASAP.)cumsum(X)\ncumprod(1 + diff(log(Y)))\nX + Y\nabs.(sin.(X))"
},

{
    "location": "overview/#Usage-1",
    "page": "Overview",
    "title": "Usage",
    "category": "section",
    "text": ""
},

{
    "location": "overview/#Data-Input/Output-1",
    "page": "Overview",
    "title": "Data Input/Output",
    "category": "section",
    "text": "There are currently several options for how to get time series data into the Julia environment as Temporal.TS objects.Data Vendor Downloads\nQuandl\nYahoo! Finance\nGoogle Finance\nLocal Flat Files (CSV, TSV, etc.)"
},

{
    "location": "overview/#Quandl-Data-Downloads-1",
    "page": "Overview",
    "title": "Quandl Data Downloads",
    "category": "section",
    "text": "corn = quandl(\"CHRIS/CME_C1\", from=\"2010-06-09\", thru=string(Dates.today()), freq=\'w\')  # weekly corn price history\ncorn = dropnan(corn)  # remove rows with any NaN"
},

{
    "location": "overview/#Yahoo!-Finance-Downloads-1",
    "page": "Overview",
    "title": "Yahoo! Finance Downloads",
    "category": "section",
    "text": "snapchat_prices = yahoo(\"SNAP\", from=\"2017-03-03\")  # historical prices for Snapchat since its IPO date\nexxon_dividends = yahoo(\"XOM\", event=\"div\", from=\"2000-01-01\", thru=\"2009-12-31\")  # all dividend payments Exxon disbursed during the 2000\'s"
},

{
    "location": "overview/#Flat-File-I/O-1",
    "page": "Overview",
    "title": "Flat File I/O",
    "category": "section",
    "text": "filepath = \"tmp.csv\"\ntswrite(corn, filepath)\ntsread(filepath) == corn"
},

{
    "location": "overview/#Subsetting/Indexing-1",
    "page": "Overview",
    "title": "Subsetting/Indexing",
    "category": "section",
    "text": "Easily one of the more important parts of handling time series data is the ability to retrieve from that time series specific portions of the data that you want. To this end, TS objects provide a fairly flexible indexing interface to make it easier to slice & dice data in the ways commonly desired, while maintaining an emphasis on speed and performance wherever possible.As an example use case, let us analyze the price history of front-month crude oil futures.crude = quandl(\"CHRIS/CME_CL1\")  # download crude oil prices from Quandl\ncrude = dropnan(crude)  # remove the missing values from the downloaded data"
},

{
    "location": "overview/#Column-Indexing-1",
    "page": "Overview",
    "title": "Column Indexing",
    "category": "section",
    "text": "The fields member of the Temporal.TS object (wherein the column names are stored) are represented using Julia\'s builtin Symbol datatype.crude[:Settle]\ncrude[[:Settle,:Volume]]\ncrude[1:100, :Volume]A series of financial extractor convenience functions are also made available for commonly used tasks involving the selection of specific fields from historical financial market data.vo(crude)  # volume\nop(crude)  # open\nhi(crude)  # high\nlo(crude)  # low\ncl(crude)  # close (note: will take fields named :Close, :AdjClose, :Settle, and :Last)ohlc(crude)\nohlcv(crude)\nhl(crude)\nhlc(crude)\nhl2(crude)   # average of high and low\nhlc3(crude)  # average of high, low, and close\nohlc4(crude) # average of open, high, low, and close"
},

{
    "location": "overview/#Row-Indexing-1",
    "page": "Overview",
    "title": "Row Indexing",
    "category": "section",
    "text": "Rows of TS objects can be indexed in much the same way as Julia\'s standard Array objects. Since time is the key differentiating characteristic of a time series dataset, however, indexing only one dimension with an integer (or array of integers) defaults to indexing along the time (row) dimension.crude[1]  # get the first row\ncrude[end,:]  # get the last row\ncrude[end-100:end, 1:4]Additionally, rows can be selected/indexed using Date or DateTime objects (whichever type corresponds to the element type of the object\'s index member).final_date = crude.index[end]\ncrude[final_date]\ncrude[collect(today()-Year(1):Day(1):today())]Finally, Temporal provides a querying interface that allows one to use a standardized string format structure to specify ranges of dates. Inspired by R\'s xts package, one of the most useful utilities for prototyping in the REPL is the ease with which one can subset out dates simply by passing easily readable character strings. Temporal implements this same logic for TS objects.On a tangential note, it\'s interesting to observe that while this indexing logic is implemented in low-level C code in other packages, this logic has been implemented in pure julia, making it far easier to read, interpret, understand, debug, and/or adapt to one\'s own purposes.crude[\"2016\"]  # retrieve all rows from the year 2016\ncrude[\"2015\", 6]  # retrive the sixth column from 2015\ncrude[\"/2017\", 1:4]  # retrieve first four columns for all rows through 2017\ncrude[\"2015/\", end-2:end]  # retrieve last three columns for the year 2015 and on\ncrude[\"2014/2015\", :Settle]  # retrieve settle prices for the years 2014 and 2015"
},

{
    "location": "overview/#Combining/Joining-1",
    "page": "Overview",
    "title": "Combining/Joining",
    "category": "section",
    "text": "gasoline = quandl(\"CHRIS/CME_RB1\")\ngasoline_settles = cl(gasoline)\ngasoline_settles.fields = [:Gasoline]\n\ncrude_settles = cl(crude)\ncrude_settles.fields[1] = :Crude;\n\n# full outer join\nA = ojoin(crude_settles, gasoline_settles)\n\n# hcat -- same as full outer join\nA = [crude_settles gasoline_settles]# can join to arrays of same size\nA = [A randn(size(A,1))]# can join to single numbers as well\nA = [A 0]# inner join -- keep points in time where both objects have observations\nijoin(crude_settles, gasoline_settles)# left join\nljoin(crude_settles, gasoline_settles)# right join\nrjoin(crude_settles, gasoline_settles)# vertical concatenation also implemented!\nfracker_era = [crude[\"/2013\"]; crude[\"2016/\"]]"
},

{
    "location": "overview/#Collapsing/Aggregating-1",
    "page": "Overview",
    "title": "Collapsing/Aggregating",
    "category": "section",
    "text": "# Get the last values observed at the end of each month\neom(crude)# (NOTE: the `eom` function returns a Boolean Vector when passed a Vector of TimeTypes)\n[crude.index eom(crude.index)]# monthly averages for all columns\ncollapse(crude, eom(crude.index), fun=mean)# Get the total yearly trading volume of crude oil\ncollapse(crude[:Volume], eoy(crude.index), fun=sum)"
},

{
    "location": "overview/#Visualization-1",
    "page": "Overview",
    "title": "Visualization",
    "category": "section",
    "text": "Visualization capabilities are made available by the plotting API\'s made available by the impressively thorough and all-encompassing Plots.jl package. Temporal uses the RecipesBase package to enable use of the whole suite of Plots.jl functionality while still permitting Temporal to precompile. The package Indicators package is used to compute the moving averages seen below.# download historical prices for crude oil futures and subset\nX = quandl(\"CHRIS/CME_CL1\")\nsubset = \"2012/\"\nx = cl(X)[subset]\nx.fields[1] = :CrudeFutures\n\n# merge with some technical indicators\nD = [x sma(x,n=200) ema(x,n=50)]\n\n# visualize the multivariate time series object\nplotlyjs()\nℓ = @layout [ a{0.7h}; b{0.3h} ]\nplot(D, c=[:black :orange :cyan], w=[4 2 2], layout=ℓ, subplot=1)\nplot!(wma(x,n=25), c=:red, w=2, subplot=1)\nbar!(X[\"2012/\",:Volume], c=:grey, alpha=0.5, layout=ℓ, subplot=2)(Image: alt text)"
},

{
    "location": "overview/#Miscellany-1",
    "page": "Overview",
    "title": "Miscellany",
    "category": "section",
    "text": ""
},

{
    "location": "overview/#Acknowledgements-1",
    "page": "Overview",
    "title": "Acknowledgements",
    "category": "section",
    "text": "This package is inspired mostly by R\'s xts package and Python\'s pandas package. Both packages expedite the often tedious process of acquiring & munging data and provide impressively well-developed and feature-rick toolkits for analysis.Many thanks also to the developers/contributors to the current Julia TimeSeries, whose code I have referred to countless times as a resource while developing this package."
},

{
    "location": "overview/#Temporal-vs.-TimeSeries-1",
    "page": "Overview",
    "title": "Temporal vs. TimeSeries",
    "category": "section",
    "text": "The existing Julia type for representing time series objects is a reasonably reliable and robust solution. However, the motivation for developing Temporal and its flagship TS type was driven by a small number of design decisions and semantics used in TimeSeries that could arguably/subjectively prove inconvenient. A few that stood out as sufficient motivation for a new package are given below.A key difference is that Temporal\'s TS type is defined to be mutable, whereas the TimeSeries TimeArray type is defined to be immutable\nSince in Julia, an object of immutable type \"is passed around (both in assignment statements and in function calls) by copying, whereas a mutable type is passed around by reference\" (see here), the TS type can be a more memory-efficient option\nThis assumes that proper care is taken to modify the object only when desired, a consideration inseparable from pass-by-reference semantics\nAdditionally, making the TS object mutable should provide greater ease & adaptability when modifying the object\'s fields\nIts indexing functionality operates differently than expected for the Array type, such that the TimeArray cannot be indexed in the same manner\nFor example, indexing columns must be done with Strings, requiring Array-like indexing syntax to be done on the underlying values member of the object\nAdditionally, this difference in indexing syntax could cause confusion for newcomers and create unnecessary headaches in basic data munging and indexing tasks\nThe syntax is similar to that of the DataFrame class in Python. While this a familiar framework, R\'s xts class is functionally equivalent to the matrix clas\nIn like fashion, a goal of this package is for the TS type to behave like an Array as much as possible, but offer more flexibility when joining/merging through the use of *temporal- indexing, to simplify challenges uniquely associated with managing time series data structures\nAnother difference between TS and TimeSeries lies in the existence of a \"metadata\" holder for the object\nWhile this feature may be useful in some cases, the TS object will likely occupy less memory than an equivalent TimeSeries object, simply because it does not hold any metadata about the object\nIn cases where such underlying metadata is of use, there are likely ways to access it without attaching it to the object\nA deliberate stylistic decision was made in giving Temporal\'s time series type a compact name\nWhile the TimeSeries package names its type TimeArray, typing out nine characters can slow one down when prototyping in the REPL\nCreating a type alias is certainly a perfectly acceptable workaround, but only having to type TS (or ts) when constructing the type can save a considerable amount of time if you\'re experimenting in the REPL for any length of time\nAdditionally, if you don\'t want to type out field names every time you instantiate a new time series, the TS class will auto-populate field names for youSo in all, the differences between the two classes are relatively stylistic, but over time will hopefully increase efficiency both when writing and running code."
},

{
    "location": "calculation/#",
    "page": "Methods",
    "title": "Methods",
    "category": "page",
    "text": ""
},

{
    "location": "calculation/#Computations-1",
    "page": "Methods",
    "title": "Computations",
    "category": "section",
    "text": ""
},

{
    "location": "calculation/#Operators-1",
    "page": "Methods",
    "title": "Operators",
    "category": "section",
    "text": "Modules = [Temporal]\nPages = [\"operations.jl\"]"
},

{
    "location": "calculation/#Scalars-1",
    "page": "Methods",
    "title": "Scalars",
    "category": "section",
    "text": "using Temporal\nX = TS(rand(100, 4))\nX + 1\nX - 1\nX * 2\nX / 2\nX % 2\nX ^ 2"
},

{
    "location": "calculation/#Time-Series-1",
    "page": "Methods",
    "title": "Time Series",
    "category": "section",
    "text": "using Temporal\nX = TS(rand(100, 4))\nY = TS(randn(100, 4))\nX + Y\nX - Y\nX * Y\nX / Y\nX % Y\nX ^ Y"
},

{
    "location": "calculation/#Statistics-1",
    "page": "Methods",
    "title": "Statistics",
    "category": "section",
    "text": "using Temporal\nX = TS(randn(100, 4))\nmean(X)\nsum(X)\nprod(X)\ncumsum(X)\ncumprod(X)\nsign(X)\nlog(X)\nminimum(X)\ncummin(X)\nmaximum(X)\ncummax(X)"
},

{
    "location": "aggregation/#",
    "page": "Aggregation",
    "title": "Aggregation",
    "category": "page",
    "text": ""
},

{
    "location": "aggregation/#Aggregation-1",
    "page": "Aggregation",
    "title": "Aggregation",
    "category": "section",
    "text": ""
},

{
    "location": "aggregation/#Sampling-1",
    "page": "Aggregation",
    "title": "Sampling",
    "category": "section",
    "text": ""
},

{
    "location": "aggregation/#Temporal.mondays",
    "page": "Aggregation",
    "title": "Temporal.mondays",
    "category": "function",
    "text": "mondays(x::TS)\n\nReturn a time series containing all observations occuring on Mondays of the given TS object.\n\n\n\n\n\n"
},

{
    "location": "aggregation/#Temporal.tuesdays",
    "page": "Aggregation",
    "title": "Temporal.tuesdays",
    "category": "function",
    "text": "tuesdays(x::TS)\n\nReturn a time series containing all observations occuring on Tuesdays of the given TS object.\n\n\n\n\n\n"
},

{
    "location": "aggregation/#Temporal.wednesdays",
    "page": "Aggregation",
    "title": "Temporal.wednesdays",
    "category": "function",
    "text": "wednesdays(x::TS)\n\nReturn a time series containing all observations occuring on Wednesdays of the given TS object.\n\n\n\n\n\n"
},

{
    "location": "aggregation/#Temporal.thursdays",
    "page": "Aggregation",
    "title": "Temporal.thursdays",
    "category": "function",
    "text": "thursdays(x::TS)\n\nReturn a time series containing all observations occuring on Thursdays of the given TS object.\n\n\n\n\n\n"
},

{
    "location": "aggregation/#Temporal.fridays",
    "page": "Aggregation",
    "title": "Temporal.fridays",
    "category": "function",
    "text": "fridays(x::TS)\n\nReturn a time series containing all observations occuring on Fridays of the given TS object.\n\n\n\n\n\n"
},

{
    "location": "aggregation/#Temporal.saturdays",
    "page": "Aggregation",
    "title": "Temporal.saturdays",
    "category": "function",
    "text": "saturdays(x::TS)\n\nReturn a time series containing all observations occuring on Saturdays of the given TS object.\n\n\n\n\n\n"
},

{
    "location": "aggregation/#Temporal.sundays",
    "page": "Aggregation",
    "title": "Temporal.sundays",
    "category": "function",
    "text": "sundays(x::TS)\n\nReturn a time series containing all observations occuring on Sundays of the given TS object.\n\n\n\n\n\n"
},

{
    "location": "aggregation/#Weekdays-1",
    "page": "Aggregation",
    "title": "Weekdays",
    "category": "section",
    "text": "mondays\ntuesdays\nwednesdays\nthursdays\nfridays\nsaturdays\nsundays"
},

{
    "location": "aggregation/#Interval-Boundaries-1",
    "page": "Aggregation",
    "title": "Interval Boundaries",
    "category": "section",
    "text": ""
},

{
    "location": "aggregation/#Temporal.bow",
    "page": "Aggregation",
    "title": "Temporal.bow",
    "category": "function",
    "text": "bow(x::TS; cal::Bool=false)\n\nReturn a time series containing all observations occuring at the beginnings of the weeks of the input.\n\nIf cal is false, only observations occurring the last calendar day of the week are returned\nIf cal is true, all observation for which the previous index is a prior week are returned\n\n\n\n\n\n"
},

{
    "location": "aggregation/#Temporal.eow",
    "page": "Aggregation",
    "title": "Temporal.eow",
    "category": "function",
    "text": "eow(x::TS; cal::Bool=false)\n\nReturn a time series containing all observations occuring at the ends of the weeks of the input.\n\nIf cal is false, only observations occurring the last calendar day of the week are returned\nIf cal is true, all observation for which the next index is a new week are returned\n\n\n\n\n\n"
},

{
    "location": "aggregation/#Weekly-1",
    "page": "Aggregation",
    "title": "Weekly",
    "category": "section",
    "text": "bow\neow"
},

{
    "location": "aggregation/#Temporal.bom",
    "page": "Aggregation",
    "title": "Temporal.bom",
    "category": "function",
    "text": "bom(x::TS; cal::Bool=false)\n\nReturn a time series containing all observations occuring at the beginnings of the months of the input.\n\nIf cal is false, only observations occurring the last calendar day of the month are returned\nIf cal is true, all observation for which the previous index is a prior month are returned\n\n\n\n\n\n"
},

{
    "location": "aggregation/#Temporal.eom",
    "page": "Aggregation",
    "title": "Temporal.eom",
    "category": "function",
    "text": "eom(x::TS; cal::Bool=false)\n\nReturn a time series containing all observations occuring at the ends of the months of the input.\n\nIf cal is false, only observations occurring the last calendar day of the month are returned\nIf cal is true, all observation for which the next index is a new month are returned\n\n\n\n\n\n"
},

{
    "location": "aggregation/#Monthly-1",
    "page": "Aggregation",
    "title": "Monthly",
    "category": "section",
    "text": "bom\neom"
},

{
    "location": "aggregation/#Temporal.boq",
    "page": "Aggregation",
    "title": "Temporal.boq",
    "category": "function",
    "text": "boq(x::TS; cal::Bool=false)\n\nReturn a time series containing all observations occuring at the beginnings of the quarters of the input.\n\nIf cal is false, only observations occurring the last calendar day of the quarter are returned\nIf cal is true, all observation for which the previous index is a prior quarter are returned\n\n\n\n\n\n"
},

{
    "location": "aggregation/#Temporal.eoq",
    "page": "Aggregation",
    "title": "Temporal.eoq",
    "category": "function",
    "text": "eoq(x::TS; cal::Bool=false)\n\nReturn a time series containing all observations occuring at the ends of the quarters of the input.\n\nIf cal is false, only observations occurring the last calendar day of the quarter are returned\nIf cal is true, all observation for which the next index is a new quarter are returned\n\n\n\n\n\n"
},

{
    "location": "aggregation/#Quarterly-1",
    "page": "Aggregation",
    "title": "Quarterly",
    "category": "section",
    "text": "boq\neoq"
},

{
    "location": "aggregation/#Temporal.boy",
    "page": "Aggregation",
    "title": "Temporal.boy",
    "category": "function",
    "text": "boy(x::TS; cal::Bool=false)\n\nReturn a time series containing all observations occuring at the beginnings of the years of the input.\n\nIf cal is false, only observations occurring the last calendar day of the year are returned\nIf cal is true, all observation for which the previous index is a prior year are returned\n\n\n\n\n\n"
},

{
    "location": "aggregation/#Temporal.eoy",
    "page": "Aggregation",
    "title": "Temporal.eoy",
    "category": "function",
    "text": "eoy(x::TS; cal::Bool=false)\n\nReturn a time series containing all observations occuring at the ends of the years of the input.\n\nIf cal is false, only observations occurring the last calendar day of the year are returned\nIf cal is true, all observation for which the next index is a new year are returned\n\n\n\n\n\n"
},

{
    "location": "aggregation/#Yearly-1",
    "page": "Aggregation",
    "title": "Yearly",
    "category": "section",
    "text": "boy\neoy"
},

{
    "location": "aggregation/#Temporal.collapse",
    "page": "Aggregation",
    "title": "Temporal.collapse",
    "category": "function",
    "text": "collapse(x::TS{V,T}, at::Function; fun::Function=last, args...)::TS{V,T} where {V,T}\n\nCompute the function fun over period boundaries defined by at (e.g. eom, boq, etc.) and returng a time series of the results.\n\nKeyword arguments (args...) are passed to the function fun.\n\n\n\n\n\n"
},

{
    "location": "aggregation/#Collapsing-1",
    "page": "Aggregation",
    "title": "Collapsing",
    "category": "section",
    "text": "collapseusing Temporal, Statistics, Dates\nX = TS(randn(100, 4))\ncollapse(X, eom, fun=mean)\nlast_month = string(X.index[end])[1:7]\nmean(X[last_month])"
},

{
    "location": "aggregation/#Temporal.apply",
    "page": "Aggregation",
    "title": "Temporal.apply",
    "category": "function",
    "text": "apply(x::TS{V}, dim::Int=1; fun=sum) where {V}\n\nApply function fun across dimension dim of a time series x.\n\nIf dim is 1, then apply fun to each row of x, returning a time series (TS) object of the results\nIf dim is 2, then apply fun to each column of x, returning an Array of the results\n\n\n\n\n\n"
},

{
    "location": "aggregation/#Summarizing-1",
    "page": "Aggregation",
    "title": "Summarizing",
    "category": "section",
    "text": "applyusing Temporal, Statistics\nX = TS(randn(100, 4))\napply(X, 1, fun=sum)\napply(X, 2, fun=sum)"
},

{
    "location": "io/#",
    "page": "I/O",
    "title": "I/O",
    "category": "page",
    "text": ""
},

{
    "location": "io/#Data-Readers-1",
    "page": "I/O",
    "title": "Data Readers",
    "category": "section",
    "text": ""
},

{
    "location": "io/#Flat-Files-1",
    "page": "I/O",
    "title": "Flat Files",
    "category": "section",
    "text": "using Temporal\nX = TS(randn(252, 4))\nfilepath = \"tmp.csv\"\ntswrite(X, filepath)\nY = tsread(filepath)\nX == Y"
},

{
    "location": "io/#Yahoo-1",
    "page": "I/O",
    "title": "Yahoo",
    "category": "section",
    "text": "using Temporal\nX = yahoo(\"FB\")"
},

{
    "location": "io/#Quandl-1",
    "page": "I/O",
    "title": "Quandl",
    "category": "section",
    "text": "using Temporal\nX = quandl(\"CHRIS/CME_CL1\", from=\"2010-01-01\")"
},

{
    "location": "indexing/#",
    "page": "Subsetting",
    "title": "Subsetting",
    "category": "page",
    "text": ""
},

{
    "location": "indexing/#Indexing-1",
    "page": "Subsetting",
    "title": "Indexing",
    "category": "section",
    "text": ""
},

{
    "location": "indexing/#Overview-1",
    "page": "Subsetting",
    "title": "Overview",
    "category": "section",
    "text": "One of the chief aims of the Temporal.jl package is to simplify the process of extracting a desired subset from a time series dataset. To that end, there are quite a few different methods by which one can index specific rows/columns of a TS object.One goal has been to keep as much of the relevant indexing operations from the base Array type as possible to maintain consistency. However, there are certain indexing idioms that are specifically more familiar and meaningful to tabular time series data, particularly when prototyping in the REPL.In other words, if you want to use standard Array indexing syntax, it should work as you would expect, but you should also be able to essentially say, \"give me all the observations from the year 2017 in the price column.\""
},

{
    "location": "indexing/#Numerical-Indexing-1",
    "page": "Subsetting",
    "title": "Numerical Indexing",
    "category": "section",
    "text": ""
},

{
    "location": "indexing/#Integer-1",
    "page": "Subsetting",
    "title": "Integer",
    "category": "section",
    "text": "using Temporal\nX = TS(cumsum(randn(252, 4), dims=1)) + 100.0\nX[1]\nX[1, :]\nX[:, 1]\nX[1, 1]"
},

{
    "location": "indexing/#Boolean-1",
    "page": "Subsetting",
    "title": "Boolean",
    "category": "section",
    "text": "using Temporal\nX = TS(cumsum(randn(252, 4), dims=1)) + 100.0\nX[trues(size(X,1)), :]\nX[rand(Bool, size(X,1)), 1]\nX[rand(Bool, size(X,1)), [true, false, false, false]]"
},

{
    "location": "indexing/#Arrays-and-Ranges-1",
    "page": "Subsetting",
    "title": "Arrays & Ranges",
    "category": "section",
    "text": "using Temporal\nX = TS(cumsum(randn(252, 4), dims=1)) + 100.0\nX[1:10, :]\nX[end-100:end, 2:3]\nX[end, 2:end]"
},

{
    "location": "indexing/#Symbol-Indexing-1",
    "page": "Subsetting",
    "title": "Symbol Indexing",
    "category": "section",
    "text": "You can also index specific columns you want using the fields member of the TS object, so that columns can be fetched by name rather than by numerical index.using Temporal\nX = TS(cumsum(randn(252, 4), dims=1)) + 100.0\nX[:, :A]\nX[:, [:B, :D]]"
},

{
    "location": "indexing/#String-Indexing-1",
    "page": "Subsetting",
    "title": "String Indexing",
    "category": "section",
    "text": "One of the more powerful features of Temporal\'s indexing functionality is that you can index rows of a TS object using Strings formatted in such a way as to express specific periods of time in a natural idiomatic way. (If you have used the xts package in R this functionality will feel very familiar.)using Dates, Temporal\nt = Date(2016,1,1):Day(1):Date(2017,12,31)\nX = TS(cumsum(randn(length(t), 4), dims=1), t) + 100.0\nX[\"2017-07-01\"]  # single day\nX[\"2016\"]  # whole year\nX[\"2016-09-15/\"]  # everything after a specific day\nX[\"/2017-07-01\"]  # everything up through a specific month\nX[\"2016-09-15/2017-07-01\"]  # mix & match"
},

{
    "location": "combining/#",
    "page": "Combining",
    "title": "Combining",
    "category": "page",
    "text": ""
},

{
    "location": "combining/#Joins-1",
    "page": "Combining",
    "title": "Joins",
    "category": "section",
    "text": "CurrentModule = Temporal"
},

{
    "location": "combining/#Base.merge",
    "page": "Combining",
    "title": "Base.merge",
    "category": "function",
    "text": "merge(x::TS,y::TS;join::Char=\'o\')::TS\n\nMerge two time series objects together by index with an optionally specified join type parameter.\n\n...\n\nArguments\n\nx::TS: Left side of the join.\ny::TS: Right side of the join.\n\nOptional args:\n\njoin::Char=\'o\'::TS: Specifies the logic used to perform the merge, and may take on the values \'o\' (outer join), \'i\' (inner join), \'l\' (left join), or \'r\' (right join). Defaults to outer join, whose result is the same as hcat(x, y) or [x y].\n\n...\n\n\n\n\n\n"
},

{
    "location": "combining/#Temporal.ojoin",
    "page": "Combining",
    "title": "Temporal.ojoin",
    "category": "function",
    "text": "ojoin(x::TS,y::TS)::TS\n\nOuter join two TS objects by index.\n\nEquivalent to x OUTER JOIN y ON x.index = y.index.\n\n...\n\nArguments\n\nx::TS: Left side of the join.\ny::TS: Right side of the join.\n\n...\n\n\n\n\n\n"
},

{
    "location": "combining/#Outer-Joins-1",
    "page": "Combining",
    "title": "Outer Joins",
    "category": "section",
    "text": "One can perform a full outer join on the time indexes of two TS objects x and y in the following ways:merge(x, y)\nojoin(x, y)\n[x y]\nhcat(x, y)Where there are dates in the index of one that do not exist in the other, values will be filled with NaN objects. As the missing functionality matures in Julia\'s base syntax, it will eventually replace NaN in this context, since unfortunately NaN is only applicable for Float64 element types.merge\nojoin"
},

{
    "location": "combining/#Example-1",
    "page": "Combining",
    "title": "Example",
    "category": "section",
    "text": "using Temporal, Dates  # hide\nx = TS(rand(252))\ny = TS(rand(252), x.index .- Month(6))\n[x y]"
},

{
    "location": "combining/#Temporal.ijoin",
    "page": "Combining",
    "title": "Temporal.ijoin",
    "category": "function",
    "text": "ijoin(x::TS,y::TS)::TS\n\nInner join two TS objects by index.\n\nEquivalent to x INNER JOIN y on x.index = y.index.\n\n...\n\nArguments\n\nx::TS: Left side of the join.\ny::TS: Right side of the join.\n\n...\n\n\n\n\n\n"
},

{
    "location": "combining/#Inner-Joins-1",
    "page": "Combining",
    "title": "Inner Joins",
    "category": "section",
    "text": "You can do inner joins on TS objects using the ijoin function, which will remove any observations corresponding to time steps where at least one of the joined objects is missing a row. This will basically keep only the rows where the time index of the left side and the right side intersect.ijoin"
},

{
    "location": "combining/#Example-2",
    "page": "Combining",
    "title": "Example",
    "category": "section",
    "text": "using Temporal, Dates  # hide\nx = TS(rand(252))\ny = TS(rand(252), x.index .- Month(6))\nijoin(x, y)"
},

{
    "location": "combining/#Temporal.ljoin",
    "page": "Combining",
    "title": "Temporal.ljoin",
    "category": "function",
    "text": "ljoin(x::TS, y::TS)::TS\n\nLeft join two TS objects by index.\n\nEquivalent to x LEFT JOIN y ON x.index = y.index.\n\n...\n\nArguments\n\nx::TS: Left side of the join.\ny::TS: Right side of the join.\n\n...\n\n\n\n\n\n"
},

{
    "location": "combining/#Temporal.rjoin",
    "page": "Combining",
    "title": "Temporal.rjoin",
    "category": "function",
    "text": "rjoin(x::TS, y::TS)::TS\n\nRight join two TS objects by index.\n\nEquivalent to x RIGHT JOIN y ON x.index = y.index.\n\n...\n\nArguments\n\nx::TS: Left side of the join.\ny::TS: Right side of the join.\n\n...\n\n\n\n\n\n"
},

{
    "location": "combining/#Left/Right-Joins-1",
    "page": "Combining",
    "title": "Left/Right Joins",
    "category": "section",
    "text": "Left and right joins are performed similarly to inner joins and the typical SQL join queries using the index field each object as the joining key.Left Join: keep all observations of the left side of the join, fill the right side with NaN\'s where missing the corresponding time index\nRight Join: keep all observations of the right side of the join, fill the left side with NaN\'s where missing the corresponding time indexljoin\nrjoin"
},

{
    "location": "combining/#Example-3",
    "page": "Combining",
    "title": "Example",
    "category": "section",
    "text": "using Temporal, Dates  # hide\nx = TS(rand(252))\ny = TS(rand(252), x.index .- Month(6))\nljoin(x, y)\nrjoin(x, y)"
},

]}
