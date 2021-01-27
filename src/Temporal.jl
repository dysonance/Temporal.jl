"""
# Temporal

Time series data analysis package for Julia.

Type and methods for time series data structures with the `TS` object.

Inspired by the pandas DataFrame in python and the xts package in R.

"""
module Temporal
    using Dates

    export
        # foundational
        TS, ts,
        # alteration
        rename!, rename,
        # combining
        ojoin, ijoin, ljoin, rjoin, merge, hcat, vcat, head, tail, subset,
        # missingness
        nanrows, nancols, dropnan, fillnan, fillnan!, ffill!, bfill!, linterp!,
        # operations
        TemporalBroadcastStyle,
        numfun, arrfun, operation,
        ones, zeros, trues, falses, isnan, countnz, sign, round,
        sum, mean, maximum, minimum, prod, cumsum, cumprod, diff, lag,
        shift, pct_change,
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
    include("data/ts.jl")
    include("data/indexing.jl")
    include("data/stringrange.jl")
    include("data/combine.jl")
    include("data/collapse.jl")
    include("data/filter.jl")
    include("util/alter.jl")
    include("util/utils.jl")
    include("util/ohlc.jl")
    include("util/convert.jl")
    include("util/show.jl")
    include("util/viz.jl")
    include("feed/utils.jl")
    include("feed/yahoo.jl")
    include("feed/google.jl")
    include("feed/quandl.jl")
    include("feed/text.jl")
    include("calc/operations.jl")
    include("calc/shift.jl")
    include("calc/models.jl")
end
