using Temporal
using Base.Test
using Base.Dates

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
dstr_rng = "$(string(dates[rng[int]]))/$(string(dates[rng[end]]))"
tstr_rng = "$(string(times[rng[int]]))/$(string(times[rng[end]]))"
date_rng = dates[1]:Week(1):dates[2]
time_rng = times[1]:Hour(1):times[2]

@testset "Temporal Tests" begin
    @testset "Initialization" begin
        @test isa(X, TS)
        @test isa(Y, TS)
        @test size(X) == size(Y) == (N, K)
        @test X.values == Y.values == data
    end
    @testset "Indexing" begin
        @testset "Single Row" begin
            @test X[int].values == data[int,:]'
            @test Y[int].values == data[int,:]'
            @test X[int,int].values == [data[int,int]]
            @test Y[int,int].values == [data[int,int]]
            @test X[int,rng].values == data[int,rng]'
            @test Y[int,rng].values == data[int,rng]'
            @test X[int,arr].values == data[int,arr]'
            @test Y[int,arr].values == data[int,arr]'
        end
        @testset "String Row Indexing" begin
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
        end
        @testset "Single Date/DateTime Row Indexing" begin
            @test X[dates[int]].values == data[int,:]'
            @test Y[times[int]].values == data[int,:]'
            @test X[dates[int],int].values == [data[int,int]]
            @test Y[times[int],int].values == [data[int,int]]
            @test X[dates[int],rng].values == data[int,rng]'
            @test Y[times[int],rng].values == data[int,rng]'
            @test X[dates[int],arr].values == data[int,rng]'
            @test Y[times[int],arr].values == data[int,rng]'
        end
        @testset "Numeric Range Row Indexing" begin
            @test X[rng].values == data[rng,:]
            @test Y[rng].values == data[rng,:]
            @test X[rng,int].values == data[rng,int]
            @test Y[rng,int].values == data[rng,int]
            @test X[rng,rng].values == data[rng,rng]
            @test Y[rng,rng].values == data[rng,rng]
            @test X[rng,arr].values == data[rng,rng]
            @test Y[rng,arr].values == data[rng,rng]

        end
        @testset "Date/DateTime Range Row Indexing" begin
            @test X[dates[rng]].values == data[rng,:]
            @test Y[times[rng]].values == data[rng,:]
            @test X[dates[rng],int].values == data[rng,int]
            @test Y[times[rng],int].values == data[rng,int]
            @test X[dates[rng],rng].values == data[rng,rng]
            @test Y[times[rng],rng].values == data[rng,rng]
            @test X[dates[rng],arr].values == data[rng,rng]
            @test Y[times[rng],arr].values == data[rng,rng]
        end
        @testset "Numeric Array Row Indexing" begin
            @test X[arr].values == data[rng,:]
            @test Y[arr].values == data[rng,:]
            @test X[arr,int].values == data[rng,int]
            @test Y[arr,int].values == data[rng,int]
            @test X[arr,rng].values == data[rng,rng]
            @test Y[arr,rng].values == data[rng,rng]
            @test X[arr,arr].values == data[rng,rng]
            @test Y[arr,arr].values == data[rng,rng]
        end
        @testset "Date/DateTime Array Row Indexing" begin
            @test X[collect(dates[rng])].values == data[rng,:]
            @test Y[collect(times[rng])].values == data[rng,:]
            @test X[collect(dates[rng]),int].values == data[rng,int]
            @test Y[collect(times[rng]),int].values == data[rng,int]
            @test X[collect(dates[rng]),rng].values == data[rng,rng]
            @test Y[collect(times[rng]),rng].values == data[rng,rng]
            @test X[collect(dates[rng]),arr].values == data[rng,rng]
            @test Y[collect(times[rng]),arr].values == data[rng,rng]
        end
        @testset "Date/DateTime Step Range Row Indexing" begin
            @test X[date_rng].values == data[rng,:]
            @test Y[time_rng].values == data[rng,:]
            @test X[date_rng,int].values == data[rng,int]
            @test Y[time_rng,int].values == data[rng,int]
            @test X[date_rng,rng].values == data[rng,rng]
            @test Y[time_rng,rng].values == data[rng,rng]
        end
    end
    @testset "Combining" begin
        X1 = copy(X)
        X2 = TS(Y.values, X1.index, Y.fields)
        X2.index = X2.index + Day(fld(N,2))
        # hcat
        Z = [X1 X2]
        @test size(Z,1) == length(union(X1.index, X2.index))
        @test size(Z,2) == size(X1,2) + size(X2,2)
        # outer joins
        Z = ojoin(X1, X2)
        @test size(Z,1) == size(X1,1) + size(X2,1)
        @test size(Z,2) == size(X1,2) + size(X2,2)
        # merges
        Z = merge(X1, X2)
        @test size(Z,1) == size(X1,1) + size(X2,1)
        @test size(Z,2) == size(X1,2) + size(X2,2)
        # inner joins
        Z = ijoin(X1, X2)
        @test size(Z,2) == size(X1,2) + size(X2,2)
        # right joins
        Z = rjoin(X1, X2)
        @test size(Z,1) == size(X1,1)
        # left joins
        Z = ljoin(X1,X2)
        @test size(Z,1) == size(X2,1)
    end
    @testset "Operations" begin
        x = X[:,1]
        y = Y[:,1]
        y.index = x.index
        # arithmetic operations
        z = x + y
        @test z.values == x.values + y.values
        z = x - y
        @test z.values == x.values - y.values
        z = x .* y
        @test z.values == x.values .* y.values
        z = x ./ y
        @test z.values == x.values ./ y.values
    end
end

