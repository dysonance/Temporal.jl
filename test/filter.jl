# module TestSlice

using Test, Dates, Temporal

@testset "Filtering" begin
    @testset "Head/Tail" begin
        X = TS(cumsum(randn(100,5), dims=1)) + 100
        n = 5
        @test head(X, n).values == X.values[1:n,:]
        @test tail(X, n).values == X.values[end-5+1:end,:]
    end
    @testset "Missing Data Removal" begin
        @testset "Rows" begin
            X = TS(cumsum(randn(100,5), dims=1)) + 100
            X[1,1] = NaN
            @test size(dropnan(X, dim=1, fun=any), 1) == size(X, 1) - 1
            @test size(dropnan(X, dim=1, fun=all), 1) == size(X, 1)
            X[1] = NaN
            @test size(dropnan(X, dim=1, fun=any), 1) == size(X, 1) - 1
            @test size(dropnan(X, dim=1, fun=all), 1) == size(X, 1) - 1
        end
        @testset "Columns" begin
            X = TS(cumsum(randn(100,5), dims=1)) + 100
            X[1,1] = NaN
            @test size(dropnan(X, dim=2, fun=any), 2) == size(X, 2) - 1
            @test size(dropnan(X, dim=2, fun=all), 2) == size(X, 2)
            X[:,1] = NaN
            @test size(dropnan(X, dim=2, fun=any), 2) == size(X, 2) - 1
            @test size(dropnan(X, dim=2, fun=all), 2) == size(X, 2) - 1
        end
    end
    @testset "Missing Data Fills" begin
        X = TS(cumsum(randn(100), dims=1)) + 100
        X[3:5] = NaN
        @test size(dropnan(fillnan(X, :ffill)), 1) == size(X, 1)
        @test size(dropnan(fillnan(X, :bfill)), 1) == size(X, 1)
        @test size(dropnan(fillnan(X, :linear)), 1) == size(X, 1)
        fillnan!(X, :bfill)
        @test all(.!nanrows(X))
        X[3:5] = NaN
        fillnan!(X, :ffill)
        @test all(.!nanrows(X))
        X[3:5] = NaN
        fillnan!(X, :linear)
        @test all(.!nanrows(X))
    end
end

# end
