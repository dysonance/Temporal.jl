# module TestMutating

using Base.Test, Base.Dates, Temporal

@testset "Mutating" begin
    @testset "Single-Element Mutations" begin
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
    end
    @testset "Row Mutations" begin
    end
    @testset "Row+Column Mutations" begin
    end
end

