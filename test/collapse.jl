using Test, Dates, Temporal

@testset "Collapsing" begin
    @testset "Periods" begin
        x = TS(rand(7))
        @test length(mondays(x)) == 1
        @test length(tuesdays(x)) == 1
        @test length(wednesdays(x)) == 1
        @test length(thursdays(x)) == 1
        @test length(fridays(x)) == 1
        @test length(saturdays(x)) == 1
        @test length(sundays(x)) == 1
        x = TS(rand(252*5))
        @test all(boy(boy(x).index)[2:end])
        @test all(eoy(eoy(x).index)[1:end-1])
        @test all(boq(boq(x).index)[2:end])
        @test all(eoq(eoq(x).index)[1:end-1])
        @test all(bom(bom(x).index)[2:end])
        @test all(eom(eom(x).index)[1:end-1])
        @test length(bow(x)) == length(mondays(x))
        @test length(eow(x)) == length(sundays(x))
    end
    @testset "Aggregation" begin
        X = TS(rand(252*5,4))
        x = X[:,1]
        m = collapse(x, eoy, fun=mean)
        prev_year = string(year(today())-1)
        @test round(m.values[end], digits=2) == round(mean(x[prev_year]), digits=2)
        m = collapse(x, (t)->eom(t,cal=true), fun=mean)
        prev_month = string(today()-Month(1))[1:7]
        @test mean(x[prev_month]) == m[prev_month].values[end]
        m = apply(X, 1, fun=mean)
        @test m.values[1] == mean(X[1].values)
        m = apply(X, 2, fun=mean)
        @test m[1] == mean(X.values[:,1])
    end
end
