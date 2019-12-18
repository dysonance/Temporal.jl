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
    show(stdout, TS(rand(252,4))[1,:])
    print("\n")
    # iterator protocol
    for (t, x) in X
        @test t in X.index
        @test size(x,1) == size(X,2)
    end
end

@testset "Rename" begin
    @testset "inplace" begin
        @testset "Pair" begin
            ts = TS(data, times, [:a, :b, :c, :d])
            rename!(ts, :a => :A)
            @test ts.fields == [:A, :b, :c, :d]
        end

        @testset "Several Pairs" begin
            ts = TS(data, times, [:a, :b, :c, :d])
            rename!(ts, :a => :A, :d => :D)
            @test ts.fields == [:A, :b, :c, :D]
        end

        @testset "Dict" begin
            ts = TS(data, times, [:a, :b, :c, :d])
            d = Dict(:a => :A, :d => :D)
            rename!(ts, d...)
            @test ts.fields == [:A, :b, :c, :D]
        end

        @testset "Lambda Function" begin
            ts = TS(data, times, [:a, :b, :c, :d])
            f = colname -> Symbol(uppercase(string(colname)))
            rename!(f, ts)
            @test ts.fields == [:A, :B, :C, :D]
        end

        @testset "Function with composition" begin
            ts = TS(data, times, [:a, :b, :c, :d])
            f = Symbol ∘ uppercase ∘ string
            rename!(f, ts)
            @test ts.fields == [:A, :B, :C, :D]
        end

        @testset "Function with do block" begin
            ts = TS(data, times, [:a, :b, :c, :d])
            rename!(ts) do x
                x |> string |> uppercase |> Symbol
            end
            @test ts.fields == [:A, :B, :C, :D]
        end

        @testset "Function with automatic String/Symbol" begin
            ts = TS(data, times, [:a, :b, :c, :d])
            rename!(uppercase, ts, String)
            @test ts.fields == [:A, :B, :C, :D]
        end
    end

    @testset "not in place" begin
        @testset "Pair" begin
            ts1 = TS(data, times, [:a, :b, :c, :d])
            ts2 = rename(ts1, :a => :A)
            @test ts1.fields == [:a, :b, :c, :d]
            @test ts2.fields == [:A, :b, :c, :d]
        end

        @testset "Several Pairs" begin
            ts1 = TS(data, times, [:a, :b, :c, :d])
            ts2 = rename(ts1, :a => :A, :d => :D)
            @test ts1.fields == [:a, :b, :c, :d]
            @test ts2.fields == [:A, :b, :c, :D]
        end

        @testset "Lambda Function" begin
            ts1 = TS(data, times, [:a, :b, :c, :d])
            f = colname -> Symbol(uppercase(string(colname)))
            ts2 = rename(f, ts1)
            @test ts1.fields == [:a, :b, :c, :d]
            @test ts2.fields == [:A, :B, :C, :D]
        end

        @testset "Function with automatic String/Symbol" begin
            ts1 = TS(data, times, [:a, :b, :c, :d])
            ts2 = rename(uppercase, ts1, String)
            @test ts1.fields == [:a, :b, :c, :d]
            @test ts2.fields == [:A, :B, :C, :D]
        end
    end
end
