VERSION >= v"0.5-" && __precompile__(true)

module Temporal
using Base.Dates
using Requests

export
    # Foundational
    TS, ts, size, overlaps,
    # Merging/Joining
    ojoin, ijoin, ljoin, rjoin, merge, hcat, vcat, head, tail,
    # Missing Data
    nanrows, nancols, dropnan, fillnan, fillnan!, ffill!, bfill!, linterp!,
    # Operations
    numfun, arrfun, op,
    ones, zeros, trues, falses, isnan, countnz, sign,
    sum, mean, maximum, minimum, prod, cumsum, cumprod, diff, lag, nans,
    # Aggregation
    mondays, tuesdays, wednesdays, thursdays, fridays, saturdays, sundays,
    bow, eow, bom, eom, boq, eoq, boy, eoy, collapse, apply,
    # IO
    tsread, tswrite, yahoo, quandl, quandl_auth, quandl_meta, quandl_search,
    # Financial
    has_open, has_high, has_low, has_close, has_volume, is_ohlc, is_ohlcv,
    open, high, low, close, volume, ohlc, ohlcv, hlc, hl
    # Modeling
    acf

include("ts.jl")
include("indexing.jl")
include("combine.jl")
include("collapse.jl")
include("operations.jl")
include("models.jl")
include("slice.jl")
include("io.jl")

end # module
