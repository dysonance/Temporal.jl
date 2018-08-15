# module TestBasics

using Test, Dates, Temporal

@testset "Initialization" begin
    @test Temporal.autocol(1:27)[end] == :AA
    @test Temporal.autoidx(2) == [today()-Day(1), today()]
    @test isa(X, TS)
    @test isa(Y, TS)
    @test size(X) == size(Y) == (N, K)
    @test X.values == Y.values == data
    @test X.index == collect(dates)
    @test Y.index == collect(times)
    @test size(TS(rand(N,K))) == (N,K)
    @test TS(X.values, X.index, ['A','B','C','D']) == X
    @test TS(X.values, X.index, ["A","B","C","D"]) == X
    @test TS(X.values[:,1], X.index, 'A') == X[:,1]
    @test TS(X.values[:,1], X.index, "A") == X[:,1]
    @test TS(X.values[1,:]', X.index[1], X.fields) == X[1]
    @test size(TS()) == (0,0)
    # underscores in colnames (issue 13)
    u = TS(rand(N), X.index, "under_score")
    @test u.fields[1] == :under_score
    show(stdout, TS(rand(252,4)))
    print("\n")
    # iterator protocol
    for (t, x) in X
        @test t in X.index
        @test size(x,1) == size(X,2)
    end
end

# end
