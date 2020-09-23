using Test, Dates, Temporal

@testset "Input/Output" begin
    @testset "Flat Files" begin
        rows, cols = 5, 3
        filepath = "tmp.csv"
        a = TS(randn(rows, cols))
        tswrite(a, filepath)
        @test filepath in readdir()
        b = tsread(filepath)
        @test a == b

        filepath = "../data/XOM.csv"
        c = tsread(filepath, format="yyyy-mm-dd")
        @test c[:Open].values[1] == 1.929688
    end
    @testset "Web Downloads" begin
        @testset "Quandl" begin
            crude = TS()
            try
                database = "CHRIS"
                table = "CME_CL1"
                crude = quandl("$database/$table", from="2016-01-01", thru=string(today()))
                @test size(crude, 2) == 8
                @test op(crude).fields == [:Open]
                meta = quandl_meta("CHRIS", "CME_CL1")
                @test meta["database_code"] == database
                perpage = 10
                search = quandl_search(db="CHRIS", qry="corn", perpage=perpage)
                @test length(search["datasets"]) == perpage
            catch
                @test_skip !isempty(crude)
            end
        end
        @testset "Yahoo" begin
            apple = TS()
            try
                apple = yahoo("AAPL", from="2016-01-01")
                @test size(apple, 2) == 6
                @test op(apple).fields == [:Open]
            catch
                @test_skip !isempty(apple)
            end
        end
        @testset "Google" begin
            apple = TS()
            try
                apple = google("AAPL", from="2016-01-01")
                @test op(apple).fields == [:Open]
            catch
                @test_skip !isempty(apple)
            end
        end
    end
end
