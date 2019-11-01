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

    module Data
        using Dates
        export
            # foundational
            TS, ts,
            # combining
            ojoin, ijoin, ljoin, rjoin, merge, hcat, vcat, head, tail, subset,
            # missingness
            nanrows, nancols, dropnan, fillnan, fillnan!, ffill!, bfill!, linterp!,
            # aggregation
            mondays, tuesdays, wednesdays, thursdays, fridays, saturdays, sundays,
            bow, eow, bom, eom, boq, eoq, boy, eoy, collapse, apply,
            # operations
            numfun, arrfun, operation,
            ones, zeros, trues, falses, isnan, countnz, sign, round,
            sum, mean, maximum, minimum, prod, cumsum, cumprod, diff, lag,
            shift, pct_change,
            rename!, rename
        include("data/ts.jl")
        include("data/indexing.jl")
        include("data/stringrange.jl")
        include("data/combine.jl")
        include("data/collapse.jl")
        include("data/filter.jl")
    end
    using .Data

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
        include("util/show.jl")
        include("util/viz.jl")
    end
    using .Util

    module Calcs
        using Temporal, Dates
        export acf
        include("calcs/models.jl")
        include("calcs/operations.jl")
    end
    using .Calcs

    module Feeds
        using Temporal, Dates
        export csvresp, tsread, tswrite, quandl, quandl_auth, quandl_meta, quandl_search, yahoo, google
        include("feeds/utils.jl")
        include("feeds/yahoo.jl")
        include("feeds/google.jl")
        include("feeds/quandl.jl")
        include("feeds/text.jl")
    end
    using .Feeds

end
