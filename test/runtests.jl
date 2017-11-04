using Temporal
using Base.Test
using Base.Dates

# constant variables
N = 100                                                 # number of observations
K = 4                                                   # number of variables
data = cumsum(randn(N,K), 1)                            # toy random data
dates = collect(today()-Week(N-1):Week(1):today())      # range of Date
times = collect(now():Hour(1):now()+Hour(N-1))          # range of DateTime
fields = ["Field $i" for i=1:K]                         # array of String field names
X = TS(data, dates)                                     # auto-generate field names
Y = TS(data, times, fields)                             # specify field names

# indexing variables
int = 1
rng = 1:2
arr = collect(rng)
dstr_row = string(dates[int])
tstr_row = string(times[int])
dstr_rng = join(string.(dates[rng], '/'))[1:end-1]
tstr_rng = join(string.(times[rng], '/'))[1:end-1]
date_rng = dates[1]:Week(1):dates[2]
time_rng = times[1]:Hour(1):times[2]

test_scripts = ["basic.jl",
                "indexing.jl",
                "combinations.jl",
                "operations.jl",
                "io.jl",
                "aggregation.jl"]

for test_script in test_scripts
    try
        include(test_script)
        println("\t\033[1m\033[32mPASSED\033[0m: $(test_script)")
    catch e
        anyerrors = true
        println("\t\033[1m\033[31mFAILED\033[0m: $(test_script)")
    end
end

