#=
Operations on TS objects
=#

import Base: ones, zeros, trues, falses
importall Base.Operators

ones(x::TS) = ts(ones(x.values), x.index, x.fields)
zeros(x::TS) = ts(zeros(x.values), x.index, x.fields)
trues(x::TS) = ts(trues(x.values), x.index, x.fields)
falses(x::TS) = ts(falses(x.values), x.index, x.fields)

function op{V,T}(x::TS{V,T}, y::TS{V,T}, fun::Function)
    idx = intersect(x.index, y.index)
    return ts(fun(x[idx].values, y[idx].values), idx, x.fields)
end

+(x::TS) = ts(+x.values, x.index, x.fields)
-(x::TS) = ts(-x.values, x.index, x.fields)
+(x::TS, y::TS) = op(x, y, +)
-(x::TS, y::TS) = op(x, y, -)
*(x::TS, y::TS) = op(x, y, *)
/(x::TS, y::TS) = op(x, y, /)
.+(x::TS, y::TS) = op(x, y, .+)
.-(x::TS, y::TS) = op(x, y, .-)
.*(x::TS, y::TS) = op(x, y, .*)
./(x::TS, y::TS) = op(x, y, ./)
.\(x::TS, y::TS) = op(x, y, .\)
.^(x::TS, y::TS) = op(x, y, .^)
.%(x::TS, y::TS) = op(x, y, .%)

+(x::TS, y::AbstractArray) = ts(x.values + y, x.index, x.fields)
-(x::TS, y::AbstractArray) = ts(x.values - y, x.index, x.fields)
*(x::TS, y::AbstractArray) = ts(x.values * y, x.index, x.fields)
/(x::TS, y::AbstractArray) = ts(x.values / y, x.index, x.fields)
.+(x::TS, y::AbstractArray) = ts(x.values .+ y, x.index, x.fields)
.-(x::TS, y::AbstractArray) = ts(x.values .- y, x.index, x.fields)
.*(x::TS, y::AbstractArray) = ts(x.values .* y, x.index, x.fields)
./(x::TS, y::AbstractArray) = ts(x.values ./ y, x.index, x.fields)
.\(x::TS, y::AbstractArray) = ts(x.values .\ y, x.index, x.fields)
.^(x::TS, y::AbstractArray) = ts(x.values .^ y, x.index, x.fields)
.%(x::TS, y::AbstractArray) = ts(x.values .% y, x.index, x.fields)

+(x::TS, y::Number) = ts(x.values + y, x.index, x.fields)
+(x::TS, y::Number) = ts(x.values + y, x.index, x.fields)
-(x::TS, y::Number) = ts(x.values - y, x.index, x.fields)
*(x::TS, y::Number) = ts(x.values * y, x.index, x.fields)
/(x::TS, y::Number) = ts(x.values / y, x.index, x.fields)
.+(x::TS, y::Number) = ts(x.values .+ y, x.index, x.fields)
.-(x::TS, y::Number) = ts(x.values .- y, x.index, x.fields)
.*(x::TS, y::Number) = ts(x.values .* y, x.index, x.fields)
./(x::TS, y::Number) = ts(x.values ./ y, x.index, x.fields)
.\(x::TS, y::Number) = ts(x.values .\ y, x.index, x.fields)
.^(x::TS, y::Number) = ts(x.values .^ y, x.index, x.fields)
.%(x::TS, y::Number) = ts(x.values .% y, x.index, x.fields)

+(y::AbstractArray, x::TS) = x + y
+(y::Number, x::TS) = x + y
