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
    X1 = copy(X)
    X2 = TS(Y.values, X1.index+Week(1), Y.fields)
    x1 = X1[:,1]
    x2 = X1[:,1]
    @testset "Combining" begin
        @testset "Joins" begin
            # outer joins
            Z = ojoin(X1, X2)
            @test size(Z,1) == length(union(X1.index, X2.index))
            @test size(Z,2) == size(X1,2) + size(X2,2)
            @test dropnan(Z) == dropnan(merge(X1, X2, join='o'))
            # inner joins
            Z = ijoin(X1, X2)
            @test size(Z,2) == size(X1,2) + size(X2,2)
            @test Z == merge(X1, X2, join='i')
            # right joins
            Z = rjoin(X1, X2)
            @test size(Z,1) == size(X1,1)
            @test dropnan(Z) == dropnan(merge(X1, X2, join='r'))
            # left joins
            Z = ljoin(X1,X2)
            @test size(Z,1) == size(X2,1)
            @test dropnan(Z) == dropnan(merge(X1, X2, join='l'))
        end
        @testset "Horizontal Concatenation" begin
            # two ts objects
            Z = [X1 X2]
            @test size(Z,1) == length(union(X1.index, X2.index))
            @test size(Z,2) == size(X2,2) + size(X2,2)
            # ts object with number
            Z = [X1 1.0]
            @test size(Z,1) == size(X1,1)
            @test size(Z,2) == size(X1,2) + 1
            # ts object with array
            Z = [X1 ones(size(X1))]
            @test size(Z,1) == size(X1,1)
            @test size(Z,2) == size(X1,2)*2
            # multiple ts objects
            Z = [X1 X2 x1 x2]
            @test size(Z,1) == length(union(X1.index, X2.index))
            @test size(Z,2) == size(X1,2) + size(X2,2) + size(x1,2) + size(x2,2)
            # ts object with multiple arrays
            Z = [X1 ones(N) 2.0+zeros(N,2)]
            @test size(Z,1) == size(X1,1)
            @test size(Z,2) == size(X1,2) + 3
            @test all(Z[:,5].values .== 1.0)
            @test all(Z[:,6:end].values .== 2.0)
            # ts object with multiple numbers
            Z = [X1 1 2.0]
            @test size(Z,1) == size(X1,1)
            @test size(Z,2) == size(X1,2) + 2
            @test all(Z[:,5].values .== 1.0)
            @test all(Z[:,6].values .== 2.0)
        end
    end
    @testset "Operations" begin
        @testset "Logical" begin
            @test x1 == x2
            @test all(trues(x1))
            @test all(!falses(x2))
            x1 += 1.0
            @test all(x1 > x2)
            @test all(x2 < x1)
            @test all(x1 >= x2)
            @test all(x2 <= x1)
        end
        @testset "Arithmetic" begin
            z = x1 + x2
            @test z.values == x1.values + x2.values
            z = x1 - x2
            @test z.values == x1.values - x2.values
            z = x1 .* x2
            @test z.values == x1.values .* x2.values
            z = x1 ./ x2
            @test z.values == x1.values ./ x2.values
            z = x1 * 2.0
            @test z.values == x1.values * 2.0
            z = x1 / 2.0
            @test z.values == x1.values / 2.0
            z = x1 % 2.0
            @test z.values == x1.values % 2.0
            #FIXME: exponent operator not working
        end
        @testset "Statistics" begin
            x = copy(x1)
            x[1] = 0.0
            @test prod(x) == prod(round(x)) == cumprod(x).values[end] == prod(x.values) == 0.0
            @test cumsum(x).values[end] ≈ sum(x) ≈ sum(x.values)
            @test mean(x) == mean(x.values)
            dx = diff(x; pad=true, padval=NaN)
            @test isnan(dx.values[1])
            @test size(dx,1) == size(x,1)
            @test size(dropnan(dx),1) == size(diff(x,pad=false),1)
            bx = lag(x; pad=true, padval=NaN)
            @test isnan(bx.values[1])
            @test size(bx,1) == size(x,1)
            @test size(dropnan(bx),1) == size(lag(x,pad=false),1)
        end
    end
end

