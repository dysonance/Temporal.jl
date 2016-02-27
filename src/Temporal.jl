VERSION >= v"0.4.0" && __precompile__(true)

using Base.Dates
module Temporal

export Str
export TS, ts, size

include("ts.jl")

end
