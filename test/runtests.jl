using Temporal
using Base.Test
using Base.Dates

n = 100                                                 # number of observations
k = 4                                                   # number of variables
data = cumsum(randn(n,k), 1)                            # toy random data
dates = collect(today()-Week(n-1):Week(1):today())      # range of Date
times = collect(now():Hour(1):now()+Hour(n-1))          # range of DateTime
fields = ["Field $i" for i=1:k]                         # array of String field names
X = ts(data, dates)                                     # auto-generate field names
Y = ts(data, times, fields)                             # specify field names

# Basic functionality
@test isa(X, TS)
@test isa(Y, TS)
@test size(X) == size(Y) == (n, k)
@test X.values == Y.values == data

# Indexing
i = 1
r = 1:2
a = collect(r)
dsr = dates[1]:Week(1):dates[2]
tsr = times[1]:Hour(1):times[2]
# Single row
@test X[i].values == data[i,:]'
@test Y[i].values == data[i,:]'
@test X[i,i].values == [data[i,i]]
@test Y[i,i].values == [data[i,i]]
@test X[i,r].values == data[i,r]'
@test Y[i,r].values == data[i,r]'
@test X[i,a].values == data[i,r]'
@test Y[i,a].values == data[i,r]'
# Single date/time
@test X[dates[i]].values == data[i,:]'
@test Y[times[i]].values == data[i,:]'
@test X[dates[i],i].values == [data[i,i]]
@test Y[times[i],i].values == [data[i,i]]
@test X[dates[i],r].values == data[i,r]'
@test Y[times[i],r].values == data[i,r]'
@test X[dates[i],a].values == data[i,r]'
@test Y[times[i],a].values == data[i,r]'
# Range of rows
@test X[r].values == data[r,:]
@test Y[r].values == data[r,:]
@test X[r,i].values == data[r,i]
@test Y[r,i].values == data[r,i]
@test X[r,r].values == data[r,r]
@test Y[r,r].values == data[r,r]
@test X[r,a].values == data[r,r]
@test Y[r,a].values == data[r,r]
# Range of dates/times
@test X[dates[r]].values == data[r,:]
@test Y[times[r]].values == data[r,:]
@test X[dates[r],i].values == data[r,i]
@test Y[times[r],i].values == data[r,i]
@test X[dates[r],r].values == data[r,r]
@test Y[times[r],r].values == data[r,r]
@test X[dates[r],a].values == data[r,r]
@test Y[times[r],a].values == data[r,r]
# Array of rows
@test X[a].values == data[r,:]
@test Y[a].values == data[r,:]
@test X[a,i].values == data[r,i]
@test Y[a,i].values == data[r,i]
@test X[a,r].values == data[r,r]
@test Y[a,r].values == data[r,r]
@test X[a,a].values == data[r,r]
@test Y[a,a].values == data[r,r]
# Array of dates/times
@test X[collect(dates[r])].values == data[r,:]
@test Y[collect(times[r])].values == data[r,:]
@test X[collect(dates[r]),i].values == data[r,i]
@test Y[collect(times[r]),i].values == data[r,i]
@test X[collect(dates[r]),r].values == data[r,r]
@test Y[collect(times[r]),r].values == data[r,r]
@test X[collect(dates[r]),a].values == data[r,r]
@test Y[collect(times[r]),a].values == data[r,r]
# Step ranges
@test X[dsr].values == data[r,:]
@test Y[tsr].values == data[r,:]
@test X[dsr,i].values == data[r,i]
@test Y[tsr,i].values == data[r,i]
@test X[dsr,r].values == data[r,r]
@test Y[tsr,r].values == data[r,r]
