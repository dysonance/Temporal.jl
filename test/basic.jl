# module TestBasics

using Base.Test, Base.Dates, Temporal

@testset "Initialization" begin
    @test isa(X, TS)
    @test isa(Y, TS)
    @test size(X) == size(Y) == (N, K)
    @test X.values == Y.values == data
    dims = (100, 4)
    @test size(TS(rand(dims))) == dims
end

# end
