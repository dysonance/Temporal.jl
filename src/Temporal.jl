VERSION >= v"0.4.0" && __precompile__(true)

using Base.Dates
module Temporal

export TS, ts, size, overlaps, tsread

include("ts.jl")
include("io.jl")

end
