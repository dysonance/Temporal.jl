import Base:
    +,
    -,
    *,
    /,
    ^,
    %,
    !,
    >,
    <,
    >=,
    <=,
    ==,
    !=,
    ===,
    !==,
    all,
    any,
    cumprod,
    cumsum,
    falses,
    findall,
    findfirst,
    findlast,
    isnan,
    log,
    maximum,
    minimum,
    ones,
    prod,
    rand,
    randn,
    round,
    sign,
    sum,
    trues,
    zeros

import Base.Broadcast:
    BroadcastStyle,
    DefaultArrayStyle,
    Broadcasted,
    broadcasted,
    broadcastable,
    broadcast,
    result_style

import Statistics:
    mean

# enable use of functions using dot operator
struct TemporalBroadcastStyle <: BroadcastStyle end
Base.BroadcastStyle(::Type{TS{V,T}}) where {V<:VALTYPE,T<:IDXTYPE} = TemporalBroadcastStyle
BroadcastStyle(::TemporalBroadcastStyle) = TemporalBroadcastStyle()
BroadcastStyle(::TemporalBroadcastStyle, ::TemporalBroadcastStyle) = TemporalBroadcastStyle()
BroadcastStyle(::DefaultArrayStyle, ::TemporalBroadcastStyle) = TemporalBroadcastStyle()
broadcastable(x::TS) = x
broadcast(f::Function, X::TS) = TS(f.(X.values), X.index, X.fields)
broadcast(f::Function, X::TS, Y::TS) = opjoined(X, Y, f)
broadcasted(::TemporalBroadcastStyle, f, X::TS) = TS(f.(X.values), X.index, X.fields)
broadcasted(::TemporalBroadcastStyle, f, X::TS, Y::TS) = opjoined(X, Y, f)
result_style(::Type{TemporalBroadcastStyle}) = TemporalBroadcastStyle()

# passthrough functions
all(x::TS) = all(x.values)
any(x::TS) = any(x.values)
findall(x::TS) = findall(x.values)
findfirst(x::TS) = findfirst(x.values)
findlast(x::TS) = findlast(x.values)

# equivalently-shaped convenience functions
ones(x::TS) = TS(ones(size(x)), x.index, x.fields)
ones(::Type{TS}, n::Int) = TS(ones(n))
ones(::Type{TS}, dims::Tuple{Int,Int}) = TS(ones(dims))
ones(::Type{TS}, r::Int, c::Int) = TS(ones(r, c))
zeros(x::TS) = TS(zeros(size(x.values)), x.index, x.fields)
zeros(::Type{TS}, n::Int) = TS(zeros(n))
zeros(::Type{TS}, r::Int, c::Int) = TS(zeros(r, c))
zeros(::Type{TS}, dims::Tuple{Int,Int}) = TS(zeros(dims))
trues(x::TS) = TS(trues(size(x)), x.index, x.fields)
falses(x::TS) = TS(falses(size(x)), x.index, x.fields)

# random numbers
rand(::Type{TS}, n::Int=1) = TS(rand(Float64, n))
rand(::Type{TS}, r::Int, c::Int) = TS(rand(Float64, r, c))
rand(::Type{TS}, dims::Tuple{Int,Int}) = TS(rand(Float64, dims))
randn(::Type{TS}, n::Int=1) = TS(randn(Float64, n))
randn(::Type{TS}, r::Int, c::Int) = TS(randn(Float64, r, c))
randn(::Type{TS}, dims::Tuple{Int,Int}) = TS(randn(Float64, dims))

# number functions
round(x::TS; digits::Int=0) = TS(round.(x.values, digits=digits), x.index, x.fields)
round(R::Type, x::TS) = TS(round.(R, x.values), x.index, x.fields)
sum(x::TS) = sum(x.values)
sum(x::TS, dim::Int) = sum(x.values, dim)
sum(f::Function, x::TS) = sum(f, x.values)
prod(x::TS) = prod(x.values)
prod(x::TS, dim::Int) = prod(x.values, dim)
maximum(x::TS) = maximum(x.values)
maximum(x::TS, dim::Int) = maximum(x.values, dim)
minimum(x::TS) = minimum(x.values)
minimum(x::TS, dim::Int) = minimum(x.values, dim)
cumsum(x::TS; dims::Int=1) = TS(cumsum(x.values, dims=dims), x.index, x.fields)
cumprod(x::TS; dims::Int=1) = TS(cumprod(x.values, dims=dims), x.index, x.fields)
mean(x::TS) = mean(x.values)

# artithmetic operators
function opjoined(x::TS, y::TS, f::Function)
    z = [x y]
    xcols = 1:size(x,2)
    ycols = size(x,2)+1:size(x,2)+size(y,2)
    a = z[:,xcols].values
    b = z[:,ycols].values
    return TS(f.(a, b), z.index)
end

# negatiion
-(x::TS) = TS(-x.values, x.index, x.fields)
!(x::TS) = TS(.!x.values, x.index, x.fields)

# ts + ts arithmetic
+(x::TS, y::TS) = opjoined(x, y, +)
-(x::TS, y::TS) = opjoined(x, y, -)
*(x::TS, y::TS) = opjoined(x, y, *)
/(x::TS, y::TS) = opjoined(x, y, /)
^(x::TS, y::TS) = opjoined(x, y, ^)
%(x::TS, y::TS) = opjoined(x, y, %)
# ts + ts logical
==(x::TS, y::TS) = x.values == y.values && x.index == y.index && x.fields == y.fields
!=(x::TS, y::TS) = x.values != y.values || x.index != y.index || x.fields != y.fields
>(x::TS, y::TS) = opjoined(x, y, >)
<(x::TS, y::TS) = opjoined(x, y, <)
>=(x::TS, y::TS) = opjoined(x, y, >=)
<=(x::TS, y::TS) = opjoined(x, y, <=)

# ts + array
+(x::TS, y::Y) where {Y<:VALARR} = x + TS(y, x.index, x.fields)
-(x::TS, y::Y) where {Y<:VALARR} = x - TS(y, x.index, x.fields)
*(x::TS, y::Y) where {Y<:VALARR} = x * TS(y, x.index, x.fields)
/(x::TS, y::Y) where {Y<:VALARR} = x / TS(y, x.index, x.fields)
%(x::TS, y::Y) where {Y<:VALARR} = x % TS(y, x.index, x.fields)
^(x::TS, y::Y) where {Y<:VALARR} = x ^ TS(y, x.index, x.fields)

+(y::Y, x::TS) where {Y<:VALARR} = TS(y, x.index, x.fields) + x
-(y::Y, x::TS) where {Y<:VALARR} = TS(y, x.index, x.fields) - x
*(y::Y, x::TS) where {Y<:VALARR} = TS(y, x.index, x.fields) * x
/(y::Y, x::TS) where {Y<:VALARR} = TS(y, x.index, x.fields) / x
%(y::Y, x::TS) where {Y<:VALARR} = TS(y, x.index, x.fields) % x
^(y::Y, x::TS) where {Y<:VALARR} = TS(y, x.index, x.fields) ^ x

+(x::TS, y::Y) where {Y<:VALTYPE} = TS(x.values .+ y, x.index, x.fields)
-(x::TS, y::Y) where {Y<:VALTYPE} = TS(x.values .- y, x.index, x.fields)
*(x::TS, y::Y) where {Y<:VALTYPE} = TS(x.values .* y, x.index, x.fields)
/(x::TS, y::Y) where {Y<:VALTYPE} = TS(x.values ./ y, x.index, x.fields)
%(x::TS, y::Y) where {Y<:VALTYPE} = TS(x.values .% y, x.index, x.fields)
^(x::TS, y::Y) where {Y<:VALTYPE} = TS(x.values .^ y, x.index, x.fields)

+(y::Y, x::TS) where {Y<:VALTYPE} = x + y
-(y::Y, x::TS) where {Y<:VALTYPE} = TS(y .- x.values, x.index, x.fields)
*(y::Y, x::TS) where {Y<:VALTYPE} = x * y
/(y::Y, x::TS) where {Y<:VALTYPE} = TS(y ./ x.values, x.index, x.fields)
%(y::Y, x::TS) where {Y<:VALTYPE} = TS(y .% x.values, x.index, x.fields)
^(y::Y, x::TS) where {Y<:VALTYPE} = TS(y .^ x.values, x.index, x.fields)
