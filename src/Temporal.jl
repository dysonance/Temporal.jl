"""
# Temporal

Time series analysis package for Julia

Type and methods for time series data structures with the `TS` object

Inspired by the pandas DataFrame in python and the xts package in R

"""
module Temporal
    const SANITIZE_NAMES = false
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
    include("indexing/getindex.jl")
    include("indexing/setindex.jl")
    include("indexing/stringrange.jl")
    include("combine.jl")
    include("collapse.jl")
    include("filter.jl")
    include("viz.jl")
    module Util
        using Temporal, Dates
        export
            findcols, findrows, namefix, namefix!, autocol, autoidx, isalphanum, findalphanum,
            has_open, has_high, has_low, has_close, has_volume, is_ohlc, is_ohlcv,
            op, hi, lo, cl, vo, ohlc, ohlcv, hlc, hl, hl2, hlc3, ohlc4,
            find_index_col
        include("util/utils.jl")
        include("util/ohlc.jl")
        include("util/convert.jl")
    end
    module Calcs
        using Temporal, Dates
        export acf
        include("calcs/models.jl")
        include("calcs/operations.jl")
    end
    module Feeds
        using Temporal, Dates
        export csvresp, tsread, tswrite, quandl, quandl_auth, quandl_meta, quandl_search, yahoo, google
        include("io/utils.jl")
        include("io/yahoo.jl")
        include("io/google.jl")
        include("io/quandl.jl")
        include("io/text.jl")
    end
    using .Util
    using .Calcs
    using .Feeds
end
