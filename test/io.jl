# module TestIO

using Base.Test, Base.Dates, Temporal

@testset "Input/Output" begin
    @testset "Sample Data" begin
        corn = tsread("$(Pkg.dir("Temporal"))/data/Corn.csv", header=true, eol='\n')
        @test size(corn, 2) == 8
        @test size(cl(corn), 2) == 1
    end
    @testset "Web Downloads" begin
        crude = quandl("CHRIS/CME_CL1", from="2010-01-01", thru=string(today()))
        @test size(crude, 2) == 8
        @test op(crude).fields == [:Open]
    end
end

# end
