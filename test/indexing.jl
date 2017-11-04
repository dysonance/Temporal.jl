# module TestIndexing

using Base.Test, Base.Dates, Temporal

@testset "Indexing" begin
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
        @test X[dstr_row,int].values == [data[int,int]]
        @test X[dstr_row,rng].values == data[int,rng]'
        @test X[dstr_row,arr].values == data[int,rng]'
        @test X[dstr_rng,int].values == data[rng,int]
        @test X[dstr_rng,rng].values == data[rng,rng]
        @test X[dstr_rng,arr].values == data[rng,arr]
        @test Y[tstr_row,int].values == [data[int,int]]
        @test Y[tstr_row,rng].values == data[int,rng]'
        @test Y[tstr_row,arr].values == data[int,rng]'
        @test Y[tstr_rng,int].values == data[rng,int]
        @test Y[tstr_rng,rng].values == data[rng,rng]
        @test Y[tstr_rng,arr].values == data[rng,arr]
    end
    @testset "Single Date/DateTime Row Indexing" begin
        @test X[dates[int]].values == data[int,:]'
        @test Y[times[int]].values == data[int,:]'
        @test X[dates[int],int].values == [data[int,int]]
        @test Y[times[int],int].values == [data[int,int]]
        @test X[dates[int],rng].values == data[int,rng]'
        @test Y[times[int],rng].values == data[int,rng]'
        @test X[dates[int],arr].values == data[int,rng]'
        @test Y[times[int],arr].values == data[int,rng]'
    end
    @testset "Numeric Range Row Indexing" begin
        @test X[rng].values == data[rng,:]
        @test Y[rng].values == data[rng,:]
        @test X[rng,int].values == data[rng,int]
        @test Y[rng,int].values == data[rng,int]
        @test X[rng,rng].values == data[rng,rng]
        @test Y[rng,rng].values == data[rng,rng]
        @test X[rng,arr].values == data[rng,rng]
        @test Y[rng,arr].values == data[rng,rng]

    end
    @testset "Date/DateTime Range Row Indexing" begin
        @test X[dates[rng]].values == data[rng,:]
        @test Y[times[rng]].values == data[rng,:]
        @test X[dates[rng],int].values == data[rng,int]
        @test Y[times[rng],int].values == data[rng,int]
        @test X[dates[rng],rng].values == data[rng,rng]
        @test Y[times[rng],rng].values == data[rng,rng]
        @test X[dates[rng],arr].values == data[rng,rng]
        @test Y[times[rng],arr].values == data[rng,rng]
    end
    @testset "Numeric Array Row Indexing" begin
        @test X[arr].values == data[rng,:]
        @test Y[arr].values == data[rng,:]
        @test X[arr,int].values == data[rng,int]
        @test Y[arr,int].values == data[rng,int]
        @test X[arr,rng].values == data[rng,rng]
        @test Y[arr,rng].values == data[rng,rng]
        @test X[arr,arr].values == data[rng,rng]
        @test Y[arr,arr].values == data[rng,rng]
    end
    @testset "Date/DateTime Array Row Indexing" begin
        @test X[collect(dates[rng])].values == data[rng,:]
        @test Y[collect(times[rng])].values == data[rng,:]
        @test X[collect(dates[rng]),int].values == data[rng,int]
        @test Y[collect(times[rng]),int].values == data[rng,int]
        @test X[collect(dates[rng]),rng].values == data[rng,rng]
        @test Y[collect(times[rng]),rng].values == data[rng,rng]
        @test X[collect(dates[rng]),arr].values == data[rng,rng]
        @test Y[collect(times[rng]),arr].values == data[rng,rng]
    end
    @testset "Date/DateTime Step Range Row Indexing" begin
        @test X[date_rng].values == data[rng,:]
        @test Y[time_rng].values == data[rng,:]
        @test X[date_rng,int].values == data[rng,int]
        @test Y[time_rng,int].values == data[rng,int]
        @test X[date_rng,rng].values == data[rng,rng]
        @test Y[time_rng,rng].values == data[rng,rng]
    end
end

# end
