# module TestMutating

using Base.Test, Base.Dates, Temporal

@testset "Mutating" begin
    @testset "Single-Element Mutations" begin
        A[1,1] = 1.0
        @test A.values[1,1] == 1.0
        A[1, :B] = 2.0
        @test A.values[1,2] == 2.0
        A[string(today()), 3] = 3.0
        @test A.values[end,3] == 3.0
        A[string(today()), :D] = 4.0
        @test A.values[end,end] == 4.0
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
    end
    @testset "Row+Column Mutations" begin
    end
end

