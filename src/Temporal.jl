__precompile__(true)

"""
# Temporal

Time series analysis package for Julia

Type and methods for time series data structures with the `TS` object

Inspired by the pandas DataFrame in python and the xts package in R

"""
module Temporal
    using Dates
    export
        # foundational
        TS, ts,
        # combining
        ojoin, ijoin, ljoin, rjoin, merge, hcat, vcat, head, tail, subset,
        # missingness
        nanrows, nancols, dropnan, fillnan, fillnan!, ffill!, bfill!, linterp!,
        # operations
        numfun, arrfun, operation,
        ones, zeros, trues, falses, isnan, countnz, sign, round,
        sum, mean, maximum, minimum, prod, cumsum, cumprod, diff, lag,
        shift, pct_change,
        rename!, rename,
        # aggregation
        mondays, tuesdays, wednesdays, thursdays, fridays, saturdays, sundays,
        bow, eow, bom, eom, boq, eoq, boy, eoy, collapse, apply,
        # financial
        has_open, has_high, has_low, has_close, has_volume, is_ohlc, is_ohlcv,
        op, hi, lo, cl, vo, ohlc, ohlcv, hlc, hl, hl2, hlc3, ohlc4,
        # models
        acf,
        # data
        tsread, tswrite, quandl, quandl_auth, quandl_meta, quandl_search, yahoo, google
    include("ts.jl")
    include("show.jl")
    include("utils.jl")
    include("indexing/getindex.jl")
    include("indexing/setindex.jl")
    include("indexing/stringrange.jl")
    include("combine.jl")
    include("collapse.jl")
    include("operations.jl")
    include("models.jl")
    include("filter.jl")
    include("ohlc.jl")
    include("convert.jl")
    include("viz.jl")
    module Feeds
        using Temporal
        using Dates
        export csvresp, tsread, tswrite, quandl, quandl_auth, quandl_meta, quandl_search, yahoo, google
        include("io/utils.jl")
        include("io/yahoo.jl")
        include("io/google.jl")
        include("io/quandl.jl")
        include("io/text.jl")
    end
    using .Feeds
end
