#  importall Base.Operators
import Base: +,
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
             one,
             ones,
             zero,
             zeros,
             rand,
             randn,
             trues,
             falses,
             isnan,
             sum,
             maximum,
             minimum,
             round,
             prod,
             cumsum,
             cumprod,
             diff,
             all,
             any,
             sign,
             findall,
             findfirst,
             findlast,
             log

import Statistics: mean
import Base.Broadcast: broadcasted, broadcastable, broadcast, materialize

# enable use of functions using dot operator
broadcastable(X::TS) = TS(X)
broadcast(f::F, X::TS) where {F<:Function} = TS(f.(X.values), X.index, X.fields)
broadcasted(f, X::TS) = TS(f.(X.values), X.index, X.fields)

findall(x::TS) = findall(x.values)
findfirst(x::TS) = findfirst(x.values)
findlast(x::TS) = findlast(x.values)

ones(x::TS{V,T}) where {V<:Real,T<:TimeType} = TS{V,T}(ones(V, size(x)), x.index, x.fields)
ones(::Type{TS{V}}, n::Int) where {V<:Real} = TS{V}(ones(V, n))
ones(::Type{TS{V}}, dims::Tuple{Int,Int}) where {V<:Real} = TS{V}(ones(V, dims))
ones(::Type{TS{V}}, r::Int, c::Int) where {V<:Real} = TS{V}(ones(V, r, c))
one(x::TS{V}) where {V<:Real} = one(V)
one(::Type{TS{V}}) where {V<:Real} = one(V)

zeros(x::TS{V,T}) where {V<:Real,T<:TimeType} = TS{V,T}(zeros(size(x.values)), x.index, x.fields)
zeros(::Type{TS{V}}, n::Int) where {V<:Real} = TS{V}(zeros(V, n))
zeros(::Type{TS{V}}, r::Int, c::Int) where {V<:Real} = TS{V}(zeros(V, r, c))
zeros(::Type{TS{V}}, dims::Tuple{Int,Int}) where {V<:Real} = TS{V}(zeros(V, dims))
zero(x::TS{V}) where {V<:Real} = zero(V)
zero(::Type{TS{V}}) where {V<:Real} = zero(V)

rand(::Type{TS}, n::Int=1) = TS(rand(Float64, n))
rand(::Type{TS}, r::Int, c::Int) = TS(rand(Float64, r, c))
rand(::Type{TS}, dims::Tuple{Int,Int}) = TS(rand(Float64, dims))

randn(::Type{TS}, n::Int=1) = TS(randn(Float64, n))
randn(::Type{TS}, r::Int, c::Int) = TS(randn(Float64, r, c))
randn(::Type{TS}, dims::Tuple{Int,Int}) = TS(randn(Float64, dims))

trues(x::TS) = TS(trues(size(x)), x.index, x.fields)
falses(x::TS) = TS(falses(size(x)), x.index, x.fields)
isnan(x::TS) = TS(isnan.(x.values), x.index, x.fields)
sign(x::TS) = TS(sign.(x.values), x.index, x.fields)
log(x::TS) = TS(log.(x.values), x.index, x.fields)
log(b::Number, x::TS) = TS(log.(b, x.values), x.index, x.fields)

# Number functions
round(x::TS{V}; digits::Int=0) where {V} = TS(round.(x.values, digits=digits), x.index, x.fields)
round(::Type{R}, x::TS) where {R} = TS(round.(R, x.values), x.index, x.fields)
sum(x::TS{V}) where {V} = sum(x.values)
sum(x::TS{V}, dim::Int) where {V} = sum(x.values, dim)
sum(f::Function, x::TS{V}) where {V} = sum(f, x.values)
mean(x::TS{V}) where {V} = mean(x.values)
mean(x::TS{V}, dim::Int) where {V} = mean(x, dim)
mean(f::Function, x::TS{V}) where {V} = mean(f, x.values)
prod(x::TS{V}) where {V} = prod(x.values)
prod(x::TS{V}, dim::Int) where {V} = prod(x.values, dim)
maximum(x::TS{V}) where {V} = maximum(x.values)
maximum(x::TS{V}, dim::Int) where {V} = maximum(x.values, dim)
minimum(x::TS{V}) where {V} = minimum(x.values)
minimum(x::TS{V}, dim::Int) where {V} = minimum(x.values, dim)
cumsum(x::TS; dims::Int=1) = TS(cumsum(x.values, dims=dims), x.index, x.fields)
cumprod(x::TS; dims::Int=1) = TS(cumprod(x.values, dims=dims), x.index, x.fields)

function rowdx!(dx::AbstractArray{T,N}, x::AbstractArray{T,N}, n::Int, r::Int=size(x,1)) where {T,N}
    idx = n > 0 ? (n+1:r) : (1:r+n)
    @inbounds for i=idx
        dx[i,:] .= x[i,:] - x[i-n,:]
    end
    nothing
end

function coldx!(dx::AbstractArray{T,N}, x::AbstractArray{T,N}, n::Int, c::Int=size(x,2)) where {T,N}
    idx = n > 0 ? (n+1:c) : (1:c+n)
    @inbounds for j=idx
        dx[:,j] .= x[:,j] - x[:,j-n]
    end
    nothing
end

function diffn(x::Array{T,N}, dim::Int=1, n::Int=1) where {T<:Number,N}
    @assert dim == 1 || dim == 2 "Argument `dim` must be 1 (rows) or 2 (columns)."
    @assert abs(n) < size(x,dim) "Argument `n` out of bounds."
    if n == 0
        return x
    end
    dx = zeros(eltype(x), size(x))
    if dim == 1
        rowdx!(dx, x, n)
    else
        coldx!(dx, x, n)
    end
    return dx
end

function diff(x::TS{V,T}, n::Int=1; dim::Int=1, pad::Bool=false, padval::V=zero(V)) where {V,T}
    @assert dim == 1 || dim == 2 "Argument dim must be either 1 (rows) or 2 (columns)."
    r = size(x, 1)
    c = size(x, 2)
    dx = diffn(x.values, dim, n)
    if dim == 1
        if pad
            idx = n>0 ? (1:n) : (r+n+1:r)
            dx[idx,:] .= padval
            return TS(dx, x.index, x.fields)
        else
            idx = n > 0 ? (n+1:r) : (1:r+n)
            return TS(dx[idx,:], x.index[idx], x.fields)
        end
    else
        if pad
            idx = n > 0 ? (1:c) : (c+1+1:c)
            dx[:,idx] .= padval
            return TS(dx, x.index, x.fields[idx])
        else
            idx = n > 0 ? (n+1:c) : (1:c+n)
            return TS(dx[:,idx], x.index, x.fields[idx])
        end
    end
end

function lag(x::TS{V,T}, n::Int=1; pad::Bool=false, padval::V=zero(V)) where {V,T}
    @assert abs(n) < size(x,1) "Argument `n` out of bounds."
    if n == 0
        return x
    elseif n > 0
        out = zeros(eltype(x), size(x))
        out[n+1:end,:] .= x.values[1:end-n,:]
    elseif n < 0
        out = zeros(eltype(x), size(x))
        out[1:end+n,:] .= x.values[1-n:end,:]
    end
    r = size(x, 1)
    c = size(x, 2)
    if pad
        idx = n>0 ? (1:n) : (r+n+1:r)
        out[idx,:] .= padval
        return TS(out, x.index, x.fields)
    else
        idx = n > 0 ? (n+1:r) : (1:r+n)
        return TS(out[idx,:], x.index[idx], x.fields)
    end
end

const shift = lag

function pct_change(x::TS{V}, n::Int=1; continuous::Bool=true, pad::Bool=false, padval::V=zero(V)) where {V}
    if continuous
        return diff(log(x), n; pad=pad, padval=padval)
    else
        if pad
            return diff(x, n, pad=pad, padval=padval) / x
        else
            return diff(x, n) / x[n+1:end,:]
        end
    end
end

# Artithmetic operators
function compare_elementwise(x::TS, y::TS, f::Function)
    x_cols = 1:size(x,2)
    y_cols = (1:size(y,2)) .+ size(x,2)
    merged = [x y]
    result = f.(merged.values[:,x_cols], merged.values[:,y_cols])
    return TS(result, merged.index)
end

+(x::TS) = TS(+x.values, x.index, x.fields)
-(x::TS) = TS(-x.values, x.index, x.fields)

+(x::TS, y::TS) = compare_elementwise(x, y, +)
-(x::TS, y::TS) = compare_elementwise(x, y, -)
*(x::TS, y::TS) = compare_elementwise(x, y, *)
/(x::TS, y::TS) = compare_elementwise(x, y, /)
^(x::TS, y::TS) = compare_elementwise(x, y, ^)
%(x::TS, y::TS) = compare_elementwise(x, y, %)

+(x::TS, y::AbstractArray) = x + TS(y, x.index, x.fields)
-(x::TS, y::AbstractArray) = x - TS(y, x.index, x.fields)
*(x::TS, y::AbstractArray) = x * TS(y, x.index, x.fields)
/(x::TS, y::AbstractArray) = x / TS(y, x.index, x.fields)
%(x::TS, y::AbstractArray) = x % TS(y, x.index, x.fields)
^(x::TS, y::AbstractArray) = x ^ TS(y, x.index, x.fields)

+(y::AbstractArray, x::TS) = TS(y, x.index, x.fields) + x
-(y::AbstractArray, x::TS) = TS(y, x.index, x.fields) - x
*(y::AbstractArray, x::TS) = TS(y, x.index, x.fields) * x
/(y::AbstractArray, x::TS) = TS(y, x.index, x.fields) / x
%(y::AbstractArray, x::TS) = TS(y, x.index, x.fields) % x
^(y::AbstractArray, x::TS) = TS(y, x.index, x.fields) ^ x

+(x::TS, y::Number) = TS(x.values .+ y, x.index, x.fields)
-(x::TS, y::Number) = TS(x.values .- y, x.index, x.fields)
*(x::TS, y::Number) = TS(x.values .* y, x.index, x.fields)
/(x::TS, y::Number) = TS(x.values ./ y, x.index, x.fields)
%(x::TS, y::Number) = TS(x.values .% y, x.index, x.fields)
^(x::TS{B}, y::E) where {B<:Real,E<:Real} = TS(x.values .^ y, x.index, x.fields)

+(y::Number, x::TS) = x + y
-(y::Number, x::TS) = TS(y .- x.values, x.index, x.fields)
*(y::Number, x::TS) = x * y
/(y::Number, x::TS) = TS(y ./ x.values, x.index, x.fields)
%(y::Number, x::TS) = TS(y .% x.values, x.index, x.fields)
^(y::Number, x::TS) = TS(y .^ x.values, x.index, x.fields)

# Logical operators
all(x::TS) = all(x.values)
any(x::TS) = any(x.values)

!(x::TS) = TS(.!x.values, x.index, x.fields)

# compared to another TS object
==(x::TS, y::TS) = x.values == y.values && x.index == y.index && x.fields == y.fields
!=(x::TS, y::TS) = !(x == y)
>(x::TS, y::TS) = compare_elementwise(x, y, >)
<(x::TS, y::TS) = compare_elementwise(x, y, <)
>=(x::TS, y::TS) = compare_elementwise(x, y, >=)
<=(x::TS, y::TS) = compare_elementwise(x, y, <=)

#  # Vectorizized operations
#  broadcast(::typeof(+), x::TS, y::TS) = TS(x.values .+ y.values, x.index, x.fields)
#  broadcast(::typeof(-), x::TS, y::TS) = TS(x.values .- y.values, x.index, x.fields)
#  broadcast(::typeof(*), x::TS, y::TS) = TS(x.values .* y.values, x.index, x.fields)
#  broadcast(::typeof(/), x::TS, y::TS) = TS(x.values ./ y.values, x.index, x.fields)
#  broadcast(::typeof(^), x::TS, y::TS) = TS(x.values .^ y.values, x.index, x.fields)
#  broadcast(::typeof(%), x::TS, y::TS) = TS(x.values .% y.values, x.index, x.fields)
#  broadcast(::typeof(+), x::TS, y::AbstractArray) = TS(x.values .+ y, x.index, x.fields)
#  broadcast(::typeof(-), x::TS, y::AbstractArray) = TS(x.values .- y, x.index, x.fields)
#  broadcast(::typeof(*), x::TS, y::AbstractArray) = TS(x.values .* y, x.index, x.fields)
#  broadcast(::typeof(/), x::TS, y::AbstractArray) = TS(x.values ./ y, x.index, x.fields)
#  broadcast(::typeof(%), x::TS, y::AbstractArray) = TS(x.values .% y, x.index, x.fields)
#  broadcast(::typeof(^), x::TS, y::AbstractArray) = TS(x.values .^ y, x.index, x.fields)
#  broadcast(::typeof(+), y::AbstractArray, x::TS) = x .+ y
#  broadcast(::typeof(-), y::AbstractArray, x::TS) = x .- y
#  broadcast(::typeof(*), y::AbstractArray, x::TS) = TS(y .* x.values, x.index, x.fields)
#  broadcast(::typeof(/), y::AbstractArray, x::TS) = TS(y ./ x.values, x.index, x.fields)
#  broadcast(::typeof(%), y::AbstractArray, x::TS) = TS(y .% x.values, x.index, x.fields)
#  broadcast(::typeof(^), y::AbstractArray, x::TS) = TS(y .^ x.values, x.index, x.fields)
#  broadcast(::typeof(+), x::TS, y::Number) = TS(x.values .+ y, x.index, x.fields)
#  broadcast(::typeof(-), x::TS, y::Number) = TS(x.values .- y, x.index, x.fields)
#  broadcast(::typeof(*), x::TS, y::Number) = TS(x.values .* y, x.index, x.fields)
#  broadcast(::typeof(/), x::TS, y::Number) = TS(x.values ./ y, x.index, x.fields)
#  broadcast(::typeof(%), x::TS, y::Number) = TS(x.values .% y, x.index, x.fields)
#  broadcast(::typeof(^), x::TS, y::Number) = TS(x.values .^ y, x.index, x.fields)
#  broadcast(::typeof(+), y::Number, x::TS) = TS(y .+ x.values, x.index, x.fields)
#  broadcast(::typeof(-), y::Number, x::TS) = TS(y .- x.values, x.index, x.fields)
#  broadcast(::typeof(*), y::Number, x::TS) = TS(y .* x.values, x.index, x.fields)
#  broadcast(::typeof(/), y::Number, x::TS) = TS(y ./ x.values, x.index, x.fields)
#  broadcast(::typeof(%), y::Number, x::TS) = TS(y .% x.values, x.index, x.fields)
#  broadcast(::typeof(^), y::Number, x::TS) = TS(y .^ x.values, x.index, x.fields)
#  broadcast(::typeof(!), x::TS) = TS(.!x.values, x.index, x.fields)
#  broadcast(::typeof(!=), x::TS, y::TS) = compare_elementwise(x, y, !=)
#  broadcast(::typeof(==), x::TS, y::TS) = compare_elementwise(x, y, ==)
#  broadcast(::typeof(>), x::TS, y::TS) = compare_elementwise(x, y, >)
#  broadcast(::typeof(<), x::TS, y::TS) = compare_elementwise(x, y, <)
#  broadcast(::typeof(>=), x::TS, y::TS) = compare_elementwise(x, y, >=)
#  broadcast(::typeof(<=), x::TS, y::TS) = compare_elementwise(x, y, <=)
