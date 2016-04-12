VERSION >= v"0.4.0" && __precompile__(true)

using Base.Dates
module Temporal

export
    TS, ts, size, overlaps,
    ojoin, ijoin, ljoin, rjoin, merge,
    dropnan, dropnil,
    ones, zeros, trues, falses,
    tsread

include("ts.jl")
include("indexing.jl")
include("combine.jl")
include("operations.jl")
include("slice.jl")
include("io.jl")

end
