# module TestBasics

using Base.Test, Base.Dates, Temporal

@testset "Initialization" begin
    @test isa(X, TS)
    @test isa(Y, TS)
    @test size(X) == size(Y) == (N, K)
    @test X.values == Y.values == data
end

# end
