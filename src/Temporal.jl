VERSION >= v"0.4.0" && __precompile__(true)

module Temporal
using Base.Dates
using Requests

export
    TS, ts, size, overlaps,
    ojoin, ijoin, ljoin, rjoin, merge, hcat, vcat, head, tail,
    nanrows, nancols, dropnan, fillnan, fillnan!, ffill!, bfill!, linterp!,
    numfun, arrfun, op,
    ones, zeros, trues, falses, isnan, countnz, sign,
    sum, mean, maximum, minimum, prod, cumsum, cumprod, diff, lag, nans,
    mondays, tuesdays, wednesdays, thursdays, fridays, saturdays, sundays, 
    bow, eow, bom, eom, boq, eoq, boy, eoy, collapse, apply,
    tsread, tswrite, yahoo, quandl, quandl_auth, quandl_meta, quandl_search,
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
