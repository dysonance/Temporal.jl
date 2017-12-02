# module TestOperations

using Base.Test, Base.Dates, Temporal

@testset "Operations" begin
    @testset "Utilities" begin
        srand(1)
        x = ts(cumsum(randn(N))) + N
        dx = diff(log(x), pad=true, padval=NaN)
        @test find(trues(x)) == collect(1:N)
        @test findfirst(trues(x)) == 1
        idx_nans = isnan(dx)
        @test find(idx_nans) == [1]
        @test findfirst(idx_nans) == 1
        @test sign(dx[find(.!idx_nans)]).values[:] == sign.(dx.values[.!isnan.(dx.values)])
        x = ts(rand(N))
        @test round(Int,x).values == round.(Int,round(x).values)
        @test ones(x).values == ones(eltype(x), size(x))
        @test zeros(x).values == zeros(eltype(x), size(x))
        @test length(rand(TS,N)) == N
        x = ts(-1.0 .* rand(N))
        y = +x
        @test all(y.values .<= 0.0)
        y = -x
        @test all(y.values .>= 0.0)
    end
    @testset "Logical" begin
        @test x1 == x2
        @test all(trues(x1))
        @test all(!falses(x2))
        x1 += 1.0
        @test x1 != x2
        @test all(x1 > x2)
        @test all(x2 < x1)
        @test all(x1 >= x2)
        @test all(x2 <= x1)
    end
    @testset "Arithmetic" begin
        x1 = TS(rand(100))
        x2 = TS(rand(100))
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
        @test z.values == x1.values .% 2.0
        @test x1 + x1.values == x1 * 2
        @test x2 - x2.values == zeros(x2)
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
    end
end

# end
