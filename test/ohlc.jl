using Temporal, Test


@testset "OHLC" begin
    data = TS(rand(252, 7))
    data.fields = [:Open, :High, :Low, :Close, :Volume, :Settle, :AdjClose]
    @test op(data).fields[1] == :Open
    @test hi(data).fields[1] == :High
    @test lo(data).fields[1] == :Low
    @test vo(data).fields[1] == :Volume
    @test cl(data).fields[1] == :AdjClose
    @test cl(data[:,1:end-1]).fields[1] == :Settle
    @test cl(data, use_adj=false, allow_settle=false).fields[1] == :Close
end
