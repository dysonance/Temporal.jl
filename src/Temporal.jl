VERSION >= v"0.4.0" && __precompile__(true)

using Base.Dates
module Temporal

export TS, ts, size, overlaps, tsread

include("ts.jl")
<<<<<<< HEAD
include("indexing.jl")
include("combine.jl")
include("operations.jl")
=======
include("io.jl")
>>>>>>> 617658a75fa4bc0a1f34f721d84baa27c7757cbe

end
