# module TestSubsetting

using Base.Test, Base.Dates, Temporal

@testset "Subsetting" begin
    @testset "Identity" begin
        @test X[] == X
        @test X[:] == X
        @test X[:,:] == X
    end
    @testset "Single Row" begin
        @test X[int].values == data[int,:]'
        @test Y[int].values == data[int,:]'
        @test X[int,int] == data[int,int]
        @test Y[int,int] == data[int,int]
        @test X[int,rng].values == data[int,rng]'
        @test Y[int,rng].values == data[int,rng]'
        @test X[int,arr].values == data[int,arr]'
        @test Y[int,arr].values == data[int,arr]'
    end
    @testset "String Row Indexing" begin
        @test X[dstr_row].values[:] == data[int,:]
        @test X[dstr_row,int].values[:] == [data[int,int]]
        @test X[dstr_row,rng].values == data[int,rng]'
        @test X[dstr_row,arr].values == data[int,rng]'
        @test X[dstr_rng,int].values[:] == data[rng,int]
        @test X[dstr_rng,rng].values == data[rng,rng]
        @test X[dstr_rng,arr].values == data[rng,arr]
        @test Y[tstr_row,int].values[:] == [data[int,int]]
        @test Y[tstr_row,rng].values == data[int,rng]'
        @test Y[tstr_row,arr].values == data[int,rng]'
        @test Y[tstr_rng,int].values[:] == data[rng,int]
        @test Y[tstr_rng,rng].values == data[rng,rng]
        @test Y[tstr_rng,arr].values == data[rng,arr]
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
        @test X["/"] == X[""] == X
        @test Y["/"] == Y[""] == Y
        @test size(X["$y2/"],1) >= size(X["$y2-$m2/"],1) >= size(X["$y2-$m2-$d2/"],1)
        @test size(X["/$y2"],1) >= size(X["/$y2-$m2"],1) >= size(X["/$y2-$m2-$d2"],1)
        @test size(X["$y1/$y2",1],1) <= size(X,1)
        @test size(X["$y1-$m1/$y2-$m2"],1) <= size(X,1)
        @test size(X["$y1-$m1-$d1/$y2-$m2-$d2"],1) <= size(X,1)
        @test size(Y["$y2/"],1) >= size(Y["$y2-$m2/"],1) >= size(Y["$y2-$m2-$d2/"],1)
        @test size(Y["/$y2"],1) >= size(Y["/$y2-$m2"],1) >= size(Y["/$y2-$m2-$d2"],1)
        @test size(Y["$y1/$y2",1],1) <= size(Y,1)
        @test size(Y["$y1-$m1/$y2-$m2"],1) <= size(Y,1)
        @test size(Y["$y1-$m1-$d1/$y2-$m2-$d2"],1) <= size(Y,1)
    end
    @testset "Single Date/DateTime Row Indexing" begin
        @test X[dates[int]].values == data[int,:]'
        @test Y[times[int]].values == data[int,:]'
        @test X[dates[int],int].values[:] == [data[int,int]]
        @test Y[times[int],int].values[:] == [data[int,int]]
        @test X[dates[int],rng].values == data[int,rng]'
        @test Y[times[int],rng].values == data[int,rng]'
        @test X[dates[int],arr].values == data[int,rng]'
        @test Y[times[int],arr].values == data[int,rng]'
    end
    @testset "Numeric Range Row Indexing" begin
        @test X[rng].values == data[rng,:]
        @test Y[rng].values == data[rng,:]
        @test X[rng,int].values[:] == data[rng,int]
        @test Y[rng,int].values[:] == data[rng,int]
        @test X[rng,rng].values == data[rng,rng]
        @test Y[rng,rng].values == data[rng,rng]
        @test X[rng,arr].values == data[rng,rng]
        @test Y[rng,arr].values == data[rng,rng]

    end
    @testset "Date/DateTime Range Row Indexing" begin
        @test X[dates[rng]].values == data[rng,:]
        @test Y[times[rng]].values == data[rng,:]
        @test X[dates[rng],int].values[:] == data[rng,int]
        @test Y[times[rng],int].values[:] == data[rng,int]
        @test X[dates[rng],rng].values == data[rng,rng]
        @test Y[times[rng],rng].values == data[rng,rng]
        @test X[dates[rng],arr].values == data[rng,rng]
        @test Y[times[rng],arr].values == data[rng,rng]
    end
    @testset "Numeric Array Row Indexing" begin
        @test X[arr].values == data[rng,:]
        @test Y[arr].values == data[rng,:]
        @test X[arr,int].values[:] == data[rng,int]
        @test Y[arr,int].values[:] == data[rng,int]
        @test X[arr,rng].values == data[rng,rng]
        @test Y[arr,rng].values == data[rng,rng]
        @test X[arr,arr].values == data[rng,rng]
        @test Y[arr,arr].values == data[rng,rng]
    end
    @testset "Date/DateTime Array Row Indexing" begin
        @test X[collect(dates[rng])].values == data[rng,:]
        @test Y[collect(times[rng])].values == data[rng,:]
        @test X[collect(dates[rng]),int].values[:] == data[rng,int]
        @test Y[collect(times[rng]),int].values[:] == data[rng,int]
        @test X[collect(dates[rng]),rng].values == data[rng,rng]
        @test Y[collect(times[rng]),rng].values == data[rng,rng]
        @test X[collect(dates[rng]),arr].values == data[rng,rng]
        @test Y[collect(times[rng]),arr].values == data[rng,rng]
    end
    @testset "Date/DateTime Step Range Row Indexing" begin
        @test X[dates[rng]].values == data[rng,:]
        @test Y[times[rng]].values == data[rng,:]
        @test X[dates[rng],int].values[:] == data[rng,int]
        @test Y[times[rng],int].values[:] == data[rng,int]
        @test X[dates[rng],rng].values == data[rng,rng]
        @test Y[times[rng],rng].values == data[rng,rng]
    end
    @testset "Symbol Column Indexing" begin
        @test X[:A] == X[:,1] == X[:,:A]
        @test X[1,:A] == X[1,1] == X.values[1,1]
        @test X[[:A,:B]] == X[:,1:2] == X[:,[:A,:B]]
    end
end

# end
