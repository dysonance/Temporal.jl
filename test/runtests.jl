using Temporal
using Base.Test
using Base.Dates

vector = 50.0 + cumsum(randn(100))
stamps = collect(today():today()+Day(99))
matrix = [vector vector+rand(100) vector-rand(100)]
fields = ["A", "B", "C"]
A = ts(matrix, stamps)  # no fields specified
B = ts(matrix, stamps, fields)  # field names A, B, and C

@test isa(A, TS)
@test isa(B, TS)
@test A.fields == ["V1", "V2", "V3"]
@test B.fields == ["A",  "B",  "C"]
@test size(A) == size(B) == (100, 3)

