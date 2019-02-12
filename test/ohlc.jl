using Temporal, Test


@testset "OHLC" begin
    data = TS(rand(252, 8))
    data.fields = [:Open, :High, :Low, :Close, :Volume, :Settle, :AdjClose, :Last]
    @test has_close(data, allow_settle=true,  allow_last=true)
    @test has_close(data, allow_settle=false, allow_last=true)
    @test has_close(data, allow_settle=false, allow_last=false)
    @test has_close(data, allow_settle=true, allow_last=false)
    @test has_open(data)
    @test has_low(data)
    @test has_high(data)
    @test has_volume(data)
    @test op(data).fields[1] == :Open
    @test hi(data).fields[1] == :High
    @test lo(data).fields[1] == :Low
    @test vo(data).fields[1] == :Volume
    @test cl(data).fields[1] == :AdjClose
    @test cl(data[:,1:end-2]).fields[1] == :Settle
    @test cl(data, use_adj=false, allow_settle=false).fields[1] == :Close
    @test ohlc(data) == data[[:Open,:High,:Low,:AdjClose]]
    @test ohlcv(data) == data[[:Open,:High,:Low,:AdjClose,:Volume]]
    @test hlc(data) == data[[:High,:Low,:AdjClose]]
    @test hl(data) == data[[:High,:Low]]
    @test hl2(data).values == apply(hl(data), fun=mean).values
    @test hlc3(data).values == apply(hlc(data), fun=mean).values
    @test ohlc4(data).values == apply(ohlc(data), fun=mean).values
end
