using Temporal
using Test
using Dates

# constant variables
N = 252*3
K = 4
data = cumsum(randn(N,K), dims=1)
dates = today()-Day(N-1):Day(1):today()
times = DateTime(dates[1]):Hour(1):DateTime(dates[1])+Hour(N-1)
X = TS(data, dates)
Y = TS(data, times)

test_scripts = [
    "basic.jl",
    "subsetting.jl",
    "mutating.jl",
    "combinations.jl",
    "operations.jl",
    "io.jl",
    "slice.jl",
    "aggregation.jl"
]

if length(ARGS) > 0
    test_scripts = ARGS
end

for test_script in test_scripts
    include(test_script)
end
