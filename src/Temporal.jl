VERSION >= v"0.6-" && __precompile__(true)

module Temporal

    if VERSION >= v"0.7-"
        using Dates
    else
        using Base.Dates
    end

    using HTTP
    using JSON
    using RecipesBase

    export
        # Foundational
        TS, ts,
        # Merging/Joining
        ojoin, ijoin, ljoin, rjoin, merge, hcat, vcat, head, tail,
        # Missing Data
        nanrows, nancols, dropnan, fillnan, fillnan!, ffill!, bfill!, linterp!,
        # Operations
        numfun, arrfun, operation,
        ones, zeros, trues, falses, isnan, countnz, sign, round,
        sum, mean, maximum, minimum, prod, cumsum, cumprod, diff, lag, nans,
        shift, pct_change,
        # Aggregation
        mondays, tuesdays, wednesdays, thursdays, fridays, saturdays, sundays,
        bow, eow, bom, eom, boq, eoq, boy, eoy, collapse, apply,
        # IO
        tsread, tswrite,
        quandl, quandl_auth, quandl_meta, quandl_search,
        yahoo_get_crumb, yahoo,
        google,
        # Financial
        has_open, has_high, has_low, has_close, has_volume, is_ohlc, is_ohlcv,
        op, hi, lo, cl, vo, ohlc, ohlcv, hlc, hl, hl2, hlc3, ohlc4,
        # Utilities
        namefix, namefix!, autoidx, findalphanum,
        SANITIZE_NAMES, RANGE_DELIMITER, set_sanitize_names_option, set_range_delimiter_option,
        # Modeling
        acf

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
    include("io.jl")
    include("ohlc.jl")
    include("viz.jl")

end
