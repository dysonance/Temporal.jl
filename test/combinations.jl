# module TestCombinations

using Test, Dates, Temporal

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
        Z = [X1 ones(N) 2.0.+zeros(N,2)]
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

# end
