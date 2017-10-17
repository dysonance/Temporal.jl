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
int = 1
rng = 1:2
arr = collect(rng)
dstr_row = string(dates[int])
tstr_row = string(times[int])
dstr_rng = "$(string(dates[rng[int]]))/$(string(dates[rng[end]]))"
tstr_rng = "$(string(times[rng[int]]))/$(string(times[rng[end]]))"
date_rng = dates[1]:Week(1):dates[2]
time_rng = times[1]:Hour(1):times[2]
# Single row
@test X[int].values == data[int,:]'
@test Y[int].values == data[int,:]'
@test X[int,int].values == [data[int,int]]
@test Y[int,int].values == [data[int,int]]
@test X[int,rng].values == data[int,rng]'
@test Y[int,rng].values == data[int,rng]'
@test X[int,arr].values == data[int,arr]'
@test Y[int,arr].values == data[int,arr]'
# Date/DateTime String row indexing
@test X[dstr_row,int].values == [data[int,int]]
@test X[dstr_row,rng].values == data[int,rng]'
@test X[dstr_row,arr].values == data[int,rng]'
@test X[dstr_rng,int].values == data[rng,int]
@test X[dstr_rng,rng].values == data[rng,rng]
@test X[dstr_rng,arr].values == data[rng,arr]
@test Y[tstr_row,int].values == [data[int,int]]
@test Y[tstr_row,rng].values == data[int,rng]'
@test Y[tstr_row,arr].values == data[int,rng]'
@test Y[tstr_rng,int].values == data[rng,int]
@test Y[tstr_rng,rng].values == data[rng,rng]
@test Y[tstr_rng,arr].values == data[rng,arr]
# Single date/time
@test X[dates[int]].values == data[int,:]'
@test Y[times[int]].values == data[int,:]'
@test X[dates[int],int].values == [data[int,int]]
@test Y[times[int],int].values == [data[int,int]]
@test X[dates[int],rng].values == data[int,rng]'
@test Y[times[int],rng].values == data[int,rng]'
@test X[dates[int],arr].values == data[int,rng]'
@test Y[times[int],arr].values == data[int,rng]'
# Range of rows
@test X[rng].values == data[rng,:]
@test Y[rng].values == data[rng,:]
@test X[rng,int].values == data[rng,int]
@test Y[rng,int].values == data[rng,int]
@test X[rng,rng].values == data[rng,rng]
@test Y[rng,rng].values == data[rng,rng]
@test X[rng,arr].values == data[rng,rng]
@test Y[rng,arr].values == data[rng,rng]
# Range of dates/times
@test X[dates[rng]].values == data[rng,:]
@test Y[times[rng]].values == data[rng,:]
@test X[dates[rng],int].values == data[rng,int]
@test Y[times[rng],int].values == data[rng,int]
@test X[dates[rng],rng].values == data[rng,rng]
@test Y[times[rng],rng].values == data[rng,rng]
@test X[dates[rng],arr].values == data[rng,rng]
@test Y[times[rng],arr].values == data[rng,rng]
# Array of rows
@test X[arr].values == data[rng,:]
@test Y[arr].values == data[rng,:]
@test X[arr,int].values == data[rng,int]
@test Y[arr,int].values == data[rng,int]
@test X[arr,rng].values == data[rng,rng]
@test Y[arr,rng].values == data[rng,rng]
@test X[arr,arr].values == data[rng,rng]
@test Y[arr,arr].values == data[rng,rng]
# Array of dates/times
@test X[collect(dates[rng])].values == data[rng,:]
@test Y[collect(times[rng])].values == data[rng,:]
@test X[collect(dates[rng]),int].values == data[rng,int]
@test Y[collect(times[rng]),int].values == data[rng,int]
@test X[collect(dates[rng]),rng].values == data[rng,rng]
@test Y[collect(times[rng]),rng].values == data[rng,rng]
@test X[collect(dates[rng]),arr].values == data[rng,rng]
@test Y[collect(times[rng]),arr].values == data[rng,rng]
# Step ranges
@test X[date_rng].values == data[rng,:]
@test Y[time_rng].values == data[rng,:]
@test X[date_rng,int].values == data[rng,int]
@test Y[time_rng,int].values == data[rng,int]
@test X[date_rng,rng].values == data[rng,rng]
@test Y[time_rng,rng].values == data[rng,rng]

# combining
Y.index = X.index
Z = [X Y]
@test size(Z,1) == size(X,1) + size(Y,1)
@test size(Z,2) == size(X,2) + size(Y,2)

Z = ojoin(X, Y)
@test size(Z,1) == size(X,1) + size(Y,1)
@test size(Z,2) == size(X,2) + size(Y,2)

Z = merge(X, Y)
@test size(Z,1) == size(X,1) + size(Y,1)
@test size(Z,2) == size(X,2) + size(Y,2)

Z = ijoin(X, Y)
@test size(Z,2) == size(X,2) + size(Y,2)

Z = rjoin(X, Y)
@test size(Z,1) == size(X,1)

Z = ljoin(X,Y)
@test size(Z,1) == size(Y,1)

# operations
y.index = x.index
z = x + y
@test z.values == x.values + y.values
z = x - y
@test z.values == x.values - y.values
z = x .* y
@test z.values == x.values .* y.values
z = x ./ y
@test z.values == x.values ./ y.values

