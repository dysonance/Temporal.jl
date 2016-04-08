VERSION >= v"0.4.0" && __precompile__(true)

using Base.Dates
module Temporal

export TS, ts, size

include("ts.jl")
include("indexing.jl")
include("combine.jl")
include("operations.jl")

end
