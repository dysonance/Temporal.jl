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
    "location": "ts/#",
    "page": "TS Object",
    "title": "TS Object",
    "category": "page",
    "text": ""
},

{
    "location": "ts/#Temporal.TS",
    "page": "TS Object",
    "title": "Temporal.TS",
    "category": "type",
    "text": "Time series type aimed at efficiency and simplicity.\n\nMotivated by the xts package in R and the pandas package in Python.\n\n\n\n\n\n"
},

{
    "location": "ts/#Construction-1",
    "page": "TS Object",
    "title": "Construction",
    "category": "section",
    "text": "Modules = [Temporal]\nOrder = [:type, :function, :constant, :macro, :module]\nPages = [\"ts.jl\"]"
},

{
    "location": "operations/#",
    "page": "Operations",
    "title": "Operations",
    "category": "page",
    "text": ""
},

{
    "location": "operations/#Operations-1",
    "page": "Operations",
    "title": "Operations",
    "category": "section",
    "text": "Modules = [Temporal]\nPages = [\"operations.jl\"]"
},

{
    "location": "io/#",
    "page": "Data Access",
    "title": "Data Access",
    "category": "page",
    "text": ""
},

{
    "location": "io/#Data-Readers-1",
    "page": "Data Access",
    "title": "Data Readers",
    "category": "section",
    "text": ""
},

{
    "location": "io/#Flat-Files-1",
    "page": "Data Access",
    "title": "Flat Files",
    "category": "section",
    "text": "using Temporal\nX = TS(randn(252, 4))\nfilepath = \"tmp.csv\"\ntswrite(X, filepath)\nY = tsread(filepath)\nX == Y"
},

{
    "location": "io/#Yahoo-1",
    "page": "Data Access",
    "title": "Yahoo",
    "category": "section",
    "text": "using Temporal\nX = yahoo(\"FB\")"
},

{
    "location": "io/#Quandl-1",
    "page": "Data Access",
    "title": "Quandl",
    "category": "section",
    "text": "using Temporal\nX = quandl(\"CHRIS/CME_CL1\", from=\"2010-01-01\")"
},

{
    "location": "indexing/#",
    "page": "Indexing",
    "title": "Indexing",
    "category": "page",
    "text": ""
},

{
    "location": "indexing/#Indexing-1",
    "page": "Indexing",
    "title": "Indexing",
    "category": "section",
    "text": ""
},

{
    "location": "indexing/#Overview-1",
    "page": "Indexing",
    "title": "Overview",
    "category": "section",
    "text": "One of the chief aims of the Temporal.jl package is to simplify the process of extracting a desired subset from a time series dataset. To that end, there are quite a few different methods by which one can index specific rows/columns of a TS object.One goal has been to keep as much of the relevant indexing operations from the base Array type as possible to maintain consistency. However, there are certain indexing idioms that are specifically more familiar and meaningful to tabular time series data, particularly when prototyping in the REPL.In other words, if you want to use standard Array indexing syntax, it should work as you would expect, but you should also be able to essentially say, \"give me all the observations from the year 2017 in the price column.\""
},

{
    "location": "indexing/#Numerical-Indexing-1",
    "page": "Indexing",
    "title": "Numerical Indexing",
    "category": "section",
    "text": ""
},

{
    "location": "indexing/#Integer-1",
    "page": "Indexing",
    "title": "Integer",
    "category": "section",
    "text": "using Temporal\nX = TS(cumsum(randn(252, 4), dims=1)) + 100.0\nX[1]\nX[1, :]\nX[:, 1]\nX[1, 1]"
},

{
    "location": "indexing/#Boolean-1",
    "page": "Indexing",
    "title": "Boolean",
    "category": "section",
    "text": "using Temporal\nX = TS(cumsum(randn(252, 4), dims=1)) + 100.0\nX[trues(size(X,1)), :]\nX[rand(Bool, size(X,1)), 1]\nX[rand(Bool, size(X,1)), [true, false, false, false]]"
},

{
    "location": "indexing/#Arrays-and-Ranges-1",
    "page": "Indexing",
    "title": "Arrays & Ranges",
    "category": "section",
    "text": "using Temporal\nX = TS(cumsum(randn(252, 4), dims=1)) + 100.0\nX[1:10, :]\nX[end-100:end, 2:3]\nX[end, 2:end]"
},

{
    "location": "indexing/#Symbol-Indexing-1",
    "page": "Indexing",
    "title": "Symbol Indexing",
    "category": "section",
    "text": "You can also index specific columns you want using the fields member of the TS object, so that columns can be fetched by name rather than by numerical index.using Temporal\nX = TS(cumsum(randn(252, 4), dims=1)) + 100.0\nX[:, :A]\nX[:, [:B, :D]]"
},

{
    "location": "indexing/#String-Indexing-1",
    "page": "Indexing",
    "title": "String Indexing",
    "category": "section",
    "text": "One of the more powerful features of Temporal\'s indexing functionality is that you can index rows of a TS object using Strings formatted in such a way as to express specific periods of time in a natural idiomatic way. (If you have used the xts package in R this functionality will feel very familiar.)using Dates, Temporal\nt = Date(2016,1,1):Day(1):Date(2017,12,31)\nX = TS(cumsum(randn(length(t), 4), dims=1), t) + 100.0\nX[\"2017-07-01\"]  # single day\nX[\"2016\"]  # whole year\nX[\"2016-09-15/\"]  # everything after a specific day\nX[\"/2017-07-01\"]  # everything up through a specific month\nX[\"2016-09-15/2017-07-01\"]  # mix & match"
},

{
    "location": "combining/#",
    "page": "Joins",
    "title": "Joins",
    "category": "page",
    "text": ""
},

{
    "location": "combining/#Joins-1",
    "page": "Joins",
    "title": "Joins",
    "category": "section",
    "text": "CurrentModule = Temporal"
},

{
    "location": "combining/#Base.merge",
    "page": "Joins",
    "title": "Base.merge",
    "category": "function",
    "text": "merge(x::TS,y::TS;join::Char=\'o\')::TS\n\nMerge two time series objects together by index with an optionally specified join type parameter.\n\n...\n\nArguments\n\nx::TS: Left side of the join.\ny::TS: Right side of the join.\n\nOptional args:\n\njoin::Char=\'o\'::TS: Specifies the logic used to perform the merge, and may take on the values \'o\' (outer join), \'i\' (inner join), \'l\' (left join), or \'r\' (right join). Defaults to outer join, whose result is the same as hcat(x, y) or [x y].\n\n...\n\n\n\n\n\n"
},

{
    "location": "combining/#Temporal.ojoin",
    "page": "Joins",
    "title": "Temporal.ojoin",
    "category": "function",
    "text": "ojoin(x::TS,y::TS)::TS\n\nOuter join two TS objects by index.\n\nEquivalent to x OUTER JOIN y ON x.index = y.index.\n\n...\n\nArguments\n\nx::TS: Left side of the join.\ny::TS: Right side of the join.\n\n...\n\n\n\n\n\n"
},

{
    "location": "combining/#Outer-Joins-1",
    "page": "Joins",
    "title": "Outer Joins",
    "category": "section",
    "text": "One can perform a full outer join on the time indexes of two TS objects x and y in the following ways:merge(x, y)\nojoin(x, y)\n[x y]\nhcat(x, y)Where there are dates in the index of one that do not exist in the other, values will be filled with NaN objects. As the missing functionality matures in Julia\'s base syntax, it will eventually replace NaN in this context, since unfortunately NaN is only applicable for Float64 element types.merge\nojoin"
},

{
    "location": "combining/#Example-1",
    "page": "Joins",
    "title": "Example",
    "category": "section",
    "text": "using Temporal, Dates  # hide\nx = TS(rand(252))\ny = TS(rand(252), x.index .- Month(6))\n[x y]"
},

{
    "location": "combining/#Temporal.ijoin",
    "page": "Joins",
    "title": "Temporal.ijoin",
    "category": "function",
    "text": "ijoin(x::TS,y::TS)::TS\n\nInner join two TS objects by index.\n\nEquivalent to x INNER JOIN y on x.index = y.index.\n\n...\n\nArguments\n\nx::TS: Left side of the join.\ny::TS: Right side of the join.\n\n...\n\n\n\n\n\n"
},

{
    "location": "combining/#Inner-Joins-1",
    "page": "Joins",
    "title": "Inner Joins",
    "category": "section",
    "text": "You can do inner joins on TS objects using the ijoin function, which will remove any observations corresponding to time steps where at least one of the joined objects is missing a row. This will basically keep only the rows where the time index of the left side and the right side intersect.ijoin"
},

{
    "location": "combining/#Example-2",
    "page": "Joins",
    "title": "Example",
    "category": "section",
    "text": "using Temporal, Dates  # hide\nx = TS(rand(252))\ny = TS(rand(252), x.index .- Month(6))\nijoin(x, y)"
},

{
    "location": "combining/#Temporal.ljoin",
    "page": "Joins",
    "title": "Temporal.ljoin",
    "category": "function",
    "text": "ljoin(x::TS, y::TS)::TS\n\nLeft join two TS objects by index.\n\nEquivalent to x LEFT JOIN y ON x.index = y.index.\n\n...\n\nArguments\n\nx::TS: Left side of the join.\ny::TS: Right side of the join.\n\n...\n\n\n\n\n\n"
},

{
    "location": "combining/#Temporal.rjoin",
    "page": "Joins",
    "title": "Temporal.rjoin",
    "category": "function",
    "text": "rjoin(x::TS, y::TS)::TS\n\nRight join two TS objects by index.\n\nEquivalent to x RIGHT JOIN y ON x.index = y.index.\n\n...\n\nArguments\n\nx::TS: Left side of the join.\ny::TS: Right side of the join.\n\n...\n\n\n\n\n\n"
},

{
    "location": "combining/#Left/Right-Joins-1",
    "page": "Joins",
    "title": "Left/Right Joins",
    "category": "section",
    "text": "Left and right joins are performed similarly to inner joins and the typical SQL join queries using the index field each object as the joining key.Left Join: keep all observations of the left side of the join, fill the right side with NaN\'s where missing the corresponding time index\nRight Join: keep all observations of the right side of the join, fill the left side with NaN\'s where missing the corresponding time indexljoin\nrjoin"
},

{
    "location": "combining/#Example-3",
    "page": "Joins",
    "title": "Example",
    "category": "section",
    "text": "using Temporal, Dates  # hide\nx = TS(rand(252))\ny = TS(rand(252), x.index .- Month(6))\nljoin(x, y)\nrjoin(x, y)"
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

]}
