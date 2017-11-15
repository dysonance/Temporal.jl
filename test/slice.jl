# module TestSlice

using Base.Test, Base.Dates, Temporal

@testset "Slicing" begin
    @testset "Head/Tail" begin
        X = TS(cumsum(randn(100,5))) + 100
        n = 5
        @test head(X, n).values = X.values[1:n,:]
        @test tail(X, n).values = X.values[end-5+1:end,:]
    end
    @testset "NaN Handling" begin
        @testset "NaN Rows" begin
            X = TS(cumsum(randn(100,5))) + 100
            X[1,1] = NaN
            @test size(dropnan(X, dim=1, fun=any), 1) == size(X, 1) - 1
            @test size(dropnan(X, dim=1, fun=all), 1) == size(X, 1)
            X[1] = NaN
            @test size(dropnan(X, dim=1, fun=any), 1) == size(X, 1) - 1
            @test size(dropnan(X, dim=1, fun=all), 1) == size(X, 1) - 1
        end
        @testset "NaN Columns" begin
            X = TS(cumsum(randn(100,5))) + 100
            X[1,1] = NaN
            @test size(dropnan(X, dim=2, fun=any), 2) == size(X, 2) - 1
            @test size(dropnan(X, dim=2, fun=all), 2) == size(X, 2)
            X[:,1] = NaN
            @test size(dropnan(X, dim=2, fun=any), 2) == size(X, 2) - 1
            @test size(dropnan(X, dim=2, fun=all), 2) == size(X, 2) - 1
        end
    end
end

# end
