# module TestSubsetting

using Test, Dates, Temporal

@testset "Subsetting" begin
    @testset "Identity" begin
        @test X[] == X
        @test X[:] == X
        @test X[:,:] == X
    end
    @testset "Single Row" begin
        @test X[1].values == data[1,:]'
        @test Y[1].values == data[1,:]'
        @test X[1,1].values[1,1] == data[1,1]
        @test Y[1,1].values[1,1] == data[1,1]
        @test X[1,1:2].values == data[1,1:2]'
        @test Y[1,1:2].values == data[1,1:2]'
        @test X[1,[1,2]].values == data[1,[1,2]]'
        @test Y[1,[1,2]].values == data[1,[1,2]]'
    end
    @testset "String Row Indexing" begin
        @testset "Basic" begin
            @test X["/"] == X[""] == X
            @test Y["/"] == Y[""] == Y
        end
        @testset "Single Observation" begin
            @testset "Date" begin
                for i in Temporal.DATE_STRING_LENGTHS
                    s = string(X.index[1])[1:i]
                    @test X[s] != 0
                end
            end
            @testset "Time" begin
                for i in Temporal.DATETIME_STRING_LENGTHS
                    s = string(Y.index[1])[1:i]
                    @test Y[s] != 0
                end
            end
        end
        @testset "Range" begin
            from_string = string(Y.index[1])
            thru_string = string(Y.index[end])
            @testset "Date" begin
                for i in Temporal.DATE_STRING_LENGTHS
                    s1 = from_string[1:i]
                    s2 = thru_string[1:i]
                    @test X["$s1/$s2"] != 0
                end
            end
            @testset "Time" begin
                for i in Temporal.DATETIME_STRING_LENGTHS
                    s1 = from_string[1:i]
                    s2 = thru_string[1:i]
                    @test Y["$s1/$s2"] != 0
                end
            end
        end
    end
    @testset "Single Date/DateTime Row Indexing" begin
        @test X[dates[1]].values == data[1,:]'
        @test Y[times[1]].values == data[1,:]'
        @test X[dates[1],1].values[:] == [data[1,1]]
        @test Y[times[1],1].values[:] == [data[1,1]]
        @test X[dates[1],1:2].values == data[1,1:2]'
        @test Y[times[1],1:2].values == data[1,1:2]'
        @test X[dates[1],[1,2]].values == data[1,1:2]'
        @test Y[times[1],[1,2]].values == data[1,1:2]'
    end
    @testset "Numeric Range Row Indexing" begin
        @test X[1:2].values == data[1:2,:]
        @test Y[1:2].values == data[1:2,:]
        @test X[1:2,1].values[:] == data[1:2,1]
        @test Y[1:2,1].values[:] == data[1:2,1]
        @test X[1:2,1:2].values == data[1:2,1:2]
        @test Y[1:2,1:2].values == data[1:2,1:2]
        @test X[1:2,[1,2]].values == data[1:2,1:2]
        @test Y[1:2,[1,2]].values == data[1:2,1:2]

    end
    @testset "Date/DateTime Range Row Indexing" begin
        @test X[dates[1:2]].values == data[1:2,:]
        @test Y[times[1:2]].values == data[1:2,:]
        @test X[dates[1:2],1].values[:] == data[1:2,1]
        @test Y[times[1:2],1].values[:] == data[1:2,1]
        @test X[dates[1:2],1:2].values == data[1:2,1:2]
        @test Y[times[1:2],1:2].values == data[1:2,1:2]
        @test X[dates[1:2],[1,2]].values == data[1:2,1:2]
        @test Y[times[1:2],[1,2]].values == data[1:2,1:2]
    end
    @testset "Numeric Array Row Indexing" begin
        @test X[[1,2]].values == data[1:2,:]
        @test Y[[1,2]].values == data[1:2,:]
        @test X[[1,2],1].values[:] == data[1:2,1]
        @test Y[[1,2],1].values[:] == data[1:2,1]
        @test X[[1,2],1:2].values == data[1:2,1:2]
        @test Y[[1,2],1:2].values == data[1:2,1:2]
        @test X[[1,2],[1,2]].values == data[1:2,1:2]
        @test Y[[1,2],[1,2]].values == data[1:2,1:2]
    end
    @testset "Date/DateTime Array Row Indexing" begin
        @test X[collect(dates[1:2])].values == data[1:2,:]
        @test Y[collect(times[1:2])].values == data[1:2,:]
        @test X[collect(dates[1:2]),1].values[:] == data[1:2,1]
        @test Y[collect(times[1:2]),1].values[:] == data[1:2,1]
        @test X[collect(dates[1:2]),1:2].values == data[1:2,1:2]
        @test Y[collect(times[1:2]),1:2].values == data[1:2,1:2]
        @test X[collect(dates[1:2]),[1,2]].values == data[1:2,1:2]
        @test Y[collect(times[1:2]),[1,2]].values == data[1:2,1:2]
    end
    @testset "Date/DateTime Step Range Row Indexing" begin
        @test X[dates[1:2]].values == data[1:2,:]
        @test Y[times[1:2]].values == data[1:2,:]
        @test X[dates[1:2],1].values[:] == data[1:2,1]
        @test Y[times[1:2],1].values[:] == data[1:2,1]
        @test X[dates[1:2],1:2].values == data[1:2,1:2]
        @test Y[times[1:2],1:2].values == data[1:2,1:2]
    end
    @testset "Symbol Column Indexing" begin
        @test X[:A] == X[:,1] == X[:,:A]
        @test X[1,:A] == X[1,1]
        @test X[[:A,:B]] == X[:,1:2] == X[:,[:A,:B]]
    end
    @testset "Pattern Filtering" begin
        @test size(subset(X, "A"), 2) == 1
        @test size(subset(X, ["A", "A"]), 2) == 1
        @test size(subset(X, ["A", "B"]), 2) == 0
    end
end

# end
