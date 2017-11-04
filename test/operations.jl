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
        @test sign(dx[find(!idx_nans)]).values[:] == sign(dx.values[!isnan(dx.values)])
    end
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

# end
