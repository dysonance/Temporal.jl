VERSION >= v"0.4.0" && __precompile__(true)

module Temporal
using Base.Dates

export
    TS, ts, size, overlaps,
    ojoin, ijoin, ljoin, rjoin, merge, hcat, vcat, head, tail,
    nanrows, nancols, dropnan, fillnan, fillnan!, ffill!, bfill!, linterp!,
    numfun, arrfun, op,
    ones, zeros, trues, falses, isnan, countnz, sign,
    sum, mean, maximum, minimum, prod, cumsum, cumprod, diff, lag, nans,
    mondays, tuesdays, wednesdays, thursdays, fridays, saturdays, sundays, 
    bow, eow, bom, eom, boq, eoq, boy, eoy, collapse,
    tsread, tswrite

include("ts.jl")
include("indexing.jl")
include("combine.jl")
include("collapse.jl")
include("operations.jl")
include("slice.jl")
include("io.jl")

end # module
