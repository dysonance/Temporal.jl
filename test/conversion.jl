using Test, Dates, Temporal


@testset "Conversion" begin
    data = (time=[DateTime(2018, 11, 21, 12, 0), DateTime(2018, 11, 21, 13, 0)], col1=[10.2, 11.2], col2=[20.2, 21.2])
    result = TS(data)
    for i in 1:size(result,1)
        @test result.index[i] == data[:time][i]
        for j in 1:size(result,2)
            @test result.values[i,j] == data[j+1][i]
        end
    end
end
