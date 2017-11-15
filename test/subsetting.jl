# module TestSubsetting

using Base.Test, Base.Dates, Temporal

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
        @testset "Single Observation" begin
            @testset "Date" begin
                s = string(X.index[1])
                @test X[s] == X[1]
                @test X[s,1].values[:] == [data[1,1]]
                @test X[s,1:2].values == data[1,1:2]'
                @test X[s,[1,2]].values == data[1,1:2]'
            end
            @testset "Time" begin
                s = string(Y.index[1])
                @test Y[s] == Y[1]
                @test Y[s,1].values[:] == [data[1,1]]
                @test Y[s,1:2].values == data[1,1:2]'
                @test Y[s,[1,2]].values == data[1,1:2]'
            end
        end
        @testset "Range" begin
            @testset "Exact" begin
                @testset "Date" begin
                    s = "$(string(X.index[1]))/$(string(X.index[2]))"
                    @test X[s,1].values[:] == data[1:2,1]
                    @test X[s,1:2].values == data[1:2,1:2]
                    @test X[s,[1,2]].values == data[1:2,[1,2]]
                end
                @testset "Time" begin
                    s = "$(string(Y.index[1]))/$(string(Y.index[2]))"
                    @test Y[s,1].values[:] == data[1:2,1]
                    @test Y[s,1:2].values == data[1:2,1:2]
                    @test Y[s,[1,2]].values == data[1:2,[1,2]]
                end
            end
            @testset "Partial" begin
                y1 = string(year(today()) - 1)
                y2 = string(year(today()))
                m1 = string(month(today() - Month(1)))
                m2 = string(month(today()))
                d1 = string(day(today()-Day(1)))
                d2 = string(day(today()))
                m1 = length(m1)==1 ? "0$m1" : m1
                m2 = length(m2)==1 ? "0$m2" : m2
                d1 = length(d1)==1 ? "0$d1" : d1
                d2 = length(d2)==1 ? "0$d2" : d2
                @testset "Date" begin
                    @test X["/"] == X[""] == X
                    @test size(X["$y2/"],1) >= size(X["$y2-$m2/"],1) >= size(X["$y2-$m2-$d2/"],1)
                    @test size(X["/$y2"],1) >= size(X["/$y2-$m2"],1) >= size(X["/$y2-$m2-$d2"],1)
                    @test size(X["$y1/$y2",1],1) <= size(X,1)
                    @test size(X["$y1-$m1/$y2-$m2"],1) <= size(X,1)
                    @test size(X["$y1-$m1-$d1/$y2-$m2-$d2"],1) <= size(X,1)
                end
                @testset "Time" begin
                    @test Y["/"] == Y[""] == Y
                    @test size(Y["$y2/"],1) >= size(Y["$y2-$m2/"],1) >= size(Y["$y2-$m2-$d2/"],1)
                    @test size(Y["/$y2"],1) >= size(Y["/$y2-$m2"],1) >= size(Y["/$y2-$m2-$d2"],1)
                    @test size(Y["$y1/$y2",1],1) <= size(Y,1)
                    @test size(Y["$y1-$m1/$y2-$m2"],1) <= size(Y,1)
                    @test size(Y["$y1-$m1-$d1/$y2-$m2-$d2"],1) <= size(Y,1)
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
end

# end
