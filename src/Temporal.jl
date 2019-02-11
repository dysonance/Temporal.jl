VERSION >= v"0.6-" && __precompile__(true)

module Temporal
    using Dates
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
    include("slice.jl")
    include("ohlc.jl")
    include("convert.jl")
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
        sum, mean, maximum, minimum, prod, cumsum, cumprod, diff, lag, nans,
        shift, pct_change,
        rename!, rename,
        # aggregation
        mondays, tuesdays, wednesdays, thursdays, fridays, saturdays, sundays,
        bow, eow, bom, eom, boq, eoq, boy, eoy, collapse, apply,
        # financial
        has_open, has_high, has_low, has_close, has_volume, is_ohlc, is_ohlcv,
        op, hi, lo, cl, vo, ohlc, ohlcv, hlc, hl, hl2, hlc3, ohlc4,
        # utilities
        namefix, namefix!, autoidx, findalphanum,
        SANITIZE_NAMES, RANGE_DELIMITER, set_sanitize_names_option, set_range_delimiter_option,
        # models
        acf
    module Data
        module Remote
            using HTTP
            using JSON
            using Dates
            using Printf
            using ....Temporal
            include("data/remote/web.jl")
            include("data/remote/yahoo.jl")
            include("data/remote/google.jl")
            include("data/remote/quandl.jl")
            export csvresp, quandl, quandl_auth, quandl_meta, quandl_search, yahoo, google
        end
        module Local
            using Dates
            using ....Temporal
            include("data/local/flat.jl")
            export tsread, tswrite
        end
        export tsread, tswrite, quandl, quandl_auth, quandl_meta, quandl_search, yahoo, google
    end
    module Visualization
        using RecipesBase
        using Dates
        using ..Temporal
        include("viz.jl")
    end
    using .Data.Remote
    using .Data.Local
    export tsread, tswrite, quandl, quandl_auth, quandl_meta, quandl_search, yahoo, google
    using .Visualization
end
