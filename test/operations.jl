using Test, Dates, Temporal, Random

import Statistics.mean

@testset "Operations" begin
    @testset "Utilities" begin
        Random.seed!(1)
        x = ts(cumsum(randn(N))) + N
        dx = diff(log.(x), pad=true, padval=NaN)
        @test findall(trues(x)) == [CartesianIndex(i,1) for i in 1:size(x,1)]
        @test findfirst(trues(x)) == CartesianIndex(1,1)
        idx_nans = isnan.(dx)
        @test findall(idx_nans) == [CartesianIndex(1,1)]
        @test findfirst(idx_nans) == CartesianIndex(1,1)
        @test sign.(dx[findall(!idx_nans)]).values[:] == sign.(dx.values[.!isnan.(dx.values)])
        x = TS(rand(N))
        @test round(Int,x).values == round.(Int,round(x).values)
        @test ones(x).values == ones(eltype(x), size(x))
        @test zeros(x).values == zeros(eltype(x), size(x))
        @test length(rand(TS,N)) == N
        @test length(rand(TS,N,K)) == N*K
        @test length(rand(TS,(N,K))) == N*K
        @test length(randn(TS,N)) == N
        @test length(randn(TS,N,K)) == N*K
        @test length(randn(TS,(N,K))) == N*K
        x = TS(-1.0 .* rand(N))
        @test all(x.values .<= 0.0)
        y = -x
        @test all(y.values .>= 0.0)
    end
    @testset "Logical" begin
        x1 = x2 = TS(rand(100))
        @test x1 == x2
        @test all(trues(x1))
        @test all(!falses(x2))
        x1 += 1.0
        @test x1 != x2
        @test all(x1 .> x2)
        @test all(x2 .< x1)
        @test all(x1 .>= x2)
        @test all(x2 .<= x1)
    end
    @testset "Arithmetic" begin
        x1 = TS(rand(100)) + 100
        x2 = TS(rand(100)) + 100
        c = Float64(pi)
        # operating with two TS objects
        @test (x1 + x2).values == x1.values + x2.values
        @test (x1 - x2).values == x1.values - x2.values
        @test (x1 * x2).values == x1.values .* x2.values
        @test (x1 / x2).values == x1.values ./ x2.values
        @test (x1 * c).values == x1.values * c
        @test (x1 / c).values == x1.values / c
        @test (x1 % c).values == x1.values .% c
        # operating with arrays on LHS
        @test x1 + x1.values == x1 * 2
        @test x2 - x2.values == zeros(x2)
        @test x1 * x2.values == TS(x1.values .* x2.values)
        @test x1 / x1.values == ones(x1)
        @test x1 % x1.values == zeros(x1)
        @test x1 ^ x1.values == TS(x1.values .^ x1.values)
        # operating with arrays on RHS
        @test x1.values + x1 == x1 * 2
        @test x2.values - x2 == zeros(x2)
        @test x1.values * x2 == TS(x1.values .* x2.values)
        @test x1.values / x1 == ones(x1)
        @test x1.values % x1 == zeros(x1)
        @test x1.values ^ x1 == TS(x1.values .^ x1.values)
        # operating with scalars
        @test (c + x1).values == (c .+ x1.values)
        @test (c - x1).values == (c .- x1.values)
        @test (c * x1).values == (c .* x1.values)
        @test (c / x1).values == (c ./ x1.values)
        @test (c % x1).values == (c .% x1.values)
        @test (c ^ x1).values == (c .^ x1.values)
    end
    @testset "Statistics" begin
        x = TS(rand(100)) + 100
        x[1] = 0.0
        @test prod(x) == prod(round(x)) == cumprod(x).values[end] == prod(x.values) == 0.0
        @test cumsum(x).values[end] ≈ sum(x) ≈ sum(x.values)
        @test mean(x) == mean(x.values)
        dx = diff(x; pad=true, padval=NaN)
        @test isnan(dx.values[1])
        @test size(dx,1) == size(x,1)
        @test size(dropnan(dx),1) == size(diff(x,pad=false),1)
        dx = pct_change(x)
        @test size(dx,1) == size(x,1)-1
        dx = pct_change(x, continuous=false, pad=false)
        @test size(dx,1) == size(x,1)-1
        dx = pct_change(x, continuous=false, pad=true)
        @test size(dx,1) == size(x,1)
        bx = lag(x, pad=true, padval=NaN)
        @test isnan(bx.values[1])
        @test size(bx,1) == size(x,1)
        @test size(dropnan(bx),1) == size(lag(x,pad=false),1)
        @test dropnan(bx) == dropnan(shift(x, pad=true, padval=NaN))
        @test acf(x)[1] == 1.0
    end
    @testset "Broadcast" begin
        @test abs.(sin.(X)).values == abs.(sin.(X.values))
    end
end
