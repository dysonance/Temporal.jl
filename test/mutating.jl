# module TestMutating

using Test, Dates, Temporal

@testset "Mutating" begin
    @testset "General" begin
        A = TS(rand(N,K))
        A[:] = 0
        @test all(A.values .== 0)
    end
    @testset "Single-Element Mutations" begin
        A = TS(rand(N,K))
        @test A.index[end] == today()
        A[1,1] = 1.0
        @test A.values[1,1] == 1.0
        A[1, :B] = 2.0
        s = string(today())
        @test A.values[1,2] == 2.0
        A[s, 3] = 3.0
        @test A.values[end,3] == 3.0
        A[s, :D] = 4.0
        @test A.values[end,end] == 4.0
        t = A.index[1]
        A[t, 1] = 1
        @test A.values[1,1] == 1
        A[t, :A] = 2
        @test A.values[1,1] == 2
    end
    @testset "Column Mutations" begin
        A = TS(rand(N,K))
        A[:,1] = 1.0
        @test all(A.values[:,1] .== 1.0)
        A[:B] = 2.0
        @test all(A.values[:,2] .== 2.0)
        A[:,[false,false,true,false]] = 3.0
        @test all(A.values[:,3] .== 3.0)
        A[:] = 4.0
        @test all(A.values .== 4.0)
        A[:,:] = 5.0
        @test all(A.values .== 5.0)
        A[:,1:2] = 0.0
        @test all(A.values[:,1:2] .== 0.0)
        A[[:A,:B]] = -1.0
        @test all(A.values[:,1:2] .== -1.0)
        A[:,[:A,:B]] = -2.0
        @test all(A.values[:,1:2] .== -2.0)
        idx = falses(K)
        idx[1] = true
        X[:,idx] = -3.0
        @test all(X.values[:,1] .== -3.0)
        # column addition/modification
        energy = TS(randn(252,2), Temporal.autoidx(252), [:Crude,:Gasoline])
        energy[:Crude] += 50
        energy[:Gasoline] += minimum(energy[:Gasoline]) + 2.0
        spread = (energy[:,2] - energy[:,1]/42.0).values
        energy[:Spread] = spread
        @test energy.fields[end] == :Spread
        @test energy.values[:,end] == spread[:]
        energy[:ExpSpread] = exp.(energy[:Spread])
        @test energy.fields[end] == :ExpSpread
        @test energy.values[:,end] == exp.(spread)[:]
        energy[:Zero] = 0.0
        @test energy.fields[end] == :Zero
        @test all(energy.values[:,end] .== 0.0)
    end
    @testset "Row Mutations" begin
        A = TS(rand(N,K))
        A[1] = 1.0
        @test all(A.values[1,:] .== 1.0)
        A[2,:] = 2.0
        @test all(A.values[2,:] .== 2.0)
        idx = falses(N)
        idx[3] = true
        A[idx] = 3.0
        @test all(A.values[3,:] .== 3.0)
        idx[3] = false
        idx[4] = true
        A[idx,:] = 4.0
        @test all(A.values[4,:] .== 4.0)
        A[today()] = 0.0
        @test all(A.values[end,:] .== 0.0)
        yr = string(year(today()))
        A[yr] = 3.14
        @test all(A[yr].values .== 3.14)
        A[yr,:] = -3.14
        @test all(A[yr].values .== -3.14)
        A[1:2] = 100.0
        @test all(A.values[1:2,:] .== 100.0)
        A[1:2] = -100.0
        @test all(A.values[1:2,:] .== -100.0)
        t = A.index[1]
        A[t] = 0.0
        @test all(A.values[1,:] .== 0.0)
        A[t,:] = 1.0
        @test all(A.values[1,:] .== 1.0)
        t = A.index[1:2]
        A[t] = 3.0
        @test all(A.values[1:2,:] .== 3.0)
    end
end

