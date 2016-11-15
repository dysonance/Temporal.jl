#=
Operations on TS objects
=#

# TODO: increase efficiency running these operations
import Base: ones, zeros, trues, falses, isnan, sum, mean, maximum, minimum, round,
prod, cumsum, cumprod, diff, all, any, countnz, sign, find, findfirst
importall Base.Operators

islogical(fun::Function) = fun in (<, .<, <=, .<=, .>, >, >=, .>=, ==, .==, !=, .!=, !)
isarithmetic(fun::Function) = fun in (+, .+, -, .-, *, .*, /, ./, %, .%, ^, .^, \, .\)
const logicals = Dict("<" => "LessThan", ".<" => "LessThan", "<=" => "LessThanEqual", ".<=" => "LessThanEqual",
                      ">" => "GreaterThan", ".>" => "GreaterThan", ">=" => "GreaterThanEqual", ".>=" => "GreaterThanEqual",
                      "==" => "Equal", ".==" => "Equal", "!=" => "NotEqual", ".!=" => "NotEqual", "!" => "Not")
const arithmetics = Dict("+" => "Plus", ".+" => "Plus", "-" => "Minus", ".-" => "Minus",
                         "*" => "Times", ".*" => "Times", "/" => "Over", "./" => "Over",
                         "%" => "Mod", ".%" => "Mod", "^" => "Power", ".^" => "Power", "\\" => "Inverse", ".\\" => "Under")

find(x::TS) = find(x.values)
findfirst(x::TS) = findfirst(x.values)
ones(x::TS) = ts(ones(x.values), x.index, x.fields)
zeros(x::TS) = ts(zeros(x.values), x.index, x.fields)
trues(x::TS) = ts(trues(x.values), x.index, x.fields)
falses(x::TS) = ts(falses(x.values), x.index, x.fields)
isnan(x::TS) = ts(isnan(x.values), x.index, x.fields)
countnz(x::TS) = countnz(x.values)
sign(x::TS) = ts(sign(x.values), x.index, x.fields)

# Pass Array operators through to underlying TS values
function  operation{V,T}(x::TS{V,T}, y::TS{V,T}, fun::Function; args...)
    if islogical(fun)
        fldstr = "$(string(x.fields[1]))$(logicals[string(fun)])$(string(y.fields[1]))"
    elseif isarithmetic(fun)
        fldstr = "$(string(x.fields[1]))$(arithmetics[string(fun)])$(string(y.fields[1]))"
    else
        fldstr = ucfirst(string(fun))
    end
    fldsym = Symbol(fldstr)
    if x.index == y.index
        return ts(fun(x.values, y.values; args...), x.index, fldsym)
    end
    idx = intersect(x.index, y.index)
    return ts(fun(x[idx].values, y[idx].values; args...), idx, fldsym)
end
operation{V,T}(x::TS{V,T}, fun::Function; args...) = ts(fun(x.values), x.index, x.fields; args...)

# Number functions
round{V}(x::TS{V}, n::Int=0)::TS{V} = ts(round(x.values,n), x.index, x.fields)
round{R}(::Type{R}, x::TS) = ts(round(R, x.values), x.index, x.fields)
sum{V}(x::TS{V})::V = sum(x.values)
sum{V}(x::TS{V}, dim::Int)::Array{V} = sum(x.values, dim)
sum{V}(f::Function, x::TS{V})::V = sum(f, x.values)
mean{V}(x::TS{V}) = mean(x.values)
mean{V}(x::TS{V}, dim::Int)::Array{V} = mean(x, dim)
mean{V}(f::Function, x::TS{V})::V = mean(f, x.values)
prod{V}(x::TS{V})::V = prod(x.values)
prod{V}(x::TS{V}, dim::Int)::Array{V} = prod(x.values, dim)
maximum{V}(x::TS{V})::V = maximum(x.values)
maximum{V}(x::TS{V}, dim::Int)::Array{V} = maximum(x.values, dim)
minimum{V}(x::TS{V})::V = minimum(x.values)
minimum{V}(x::TS{V}, dim::Int)::Array{V} = minimum(x.values, dim)
cumsum(x::TS, dim::Int=1) = ts(cumsum(x.values, dim), x.index, x.fields)
cummin(x::TS, dim::Int=1) = ts(cummin(x.values, dim), x.index, x.fields)
cummax(x::TS, dim::Int=1) = ts(cummax(x.values, dim), x.index, x.fields)
cumprod(x::TS, dim::Int=1) = ts(cumprod(x.values, dim), x.index, x.fields)

nans(r::Int, c::Int) = fill(NaN, 1, 2)
nans(dims::Tuple{Int,Int}) = fill(NaN, dims)
function rowdx!{T,N}(dx::AbstractArray{T,N}, x::AbstractArray{T,N}, n::Int, r::Int=size(x,1))
    idx = n > 0 ? (n+1:r) : (1:r+n)
    @inbounds for i=idx
        dx[i,:] = x[i,:] - x[i-n,:]
    end
    nothing
end
function coldx!{T,N}(dx::AbstractArray{T,N}, x::AbstractArray{T,N}, n::Int, c::Int=size(x,2))
    idx = n > 0 ? (n+1:c) : (1:c+n)
    @inbounds for j=idx
        dx[:,j] = x[:,j] - x[:,j-n]
    end
    nothing
end
function diffn{T<:Number,N}(x::Array{T,N}, dim::Int=1, n::Int=1)
    @assert dim == 1 || dim == 2 "Argument `dim` must be 1 (rows) or 2 (columns)."
    @assert abs(n) < size(x,dim) "Argument `n` out of bounds."
    if n == 0
        return x
    end
    dx = zeros(x)
    if dim == 1
        rowdx!(dx, x, n)
    else
        coldx!(dx, x, n)
    end
    return dx
end
function diff{V,T}(x::TS{V,T}, n::Int=1; dim::Int=1, pad::Bool=false, padval::V=zero(V))
    @assert dim == 1 || dim == 2 "Argument dim must be either 1 (rows) or 2 (columns)."
    r = size(x, 1)
    c = size(x, 2)
    dx = diffn(x.values, dim, n)
    if dim == 1
        if pad
            idx = n>0 ? (1:n) : (r+n+1:r)
            dx[idx,:] = padval
            return ts(dx, x.index, x.fields)
        else
            idx = n > 0 ? (n+1:r) : (1:r+n)
            return ts(dx[idx,:], x.index[idx], x.fields)
        end
    else
        if pad
            idx = n > 0 ? (1:c) : (c+1+1:c)
            dx[:,idx] = padval
            return ts(dx, x.index, x.fields[idx])
        else
            idx = n > 0 ? (n+1:c) : (1:c+n)
            return ts(dx[:,idx], x.index, x.fields[idx])
        end
    end
end
function lag{V,T}(x::TS{V,T}, n::Int=1; pad::Bool=false, padval::V=zero(V))
	@assert abs(n) < size(x,1) "Argument `n` out of bounds."
	if n == 0
		return x
	elseif n > 0
		out = zeros(x.values)
		out[n+1:end,:] = x.values[1:end-n,:]
	elseif n < 0
		out = zeros(x.values)
		out[1:end+n,:] = x.values[1-n:end,:]
	end
    r = size(x, 1)
    c = size(x, 2)
    if pad
        idx = n>0 ? (1:n) : (r+n+1:r)
        out[idx,:] = padval
        return ts(out, x.index, x.fields)
    else
        idx = n > 0 ? (n+1:r) : (1:r+n)
        return ts(out[idx,:], x.index[idx], x.fields)
    end
end

# Artithmetic operators
+(x::TS) = ts(+x.values, x.index, x.fields)
-(x::TS) = ts(-x.values, x.index, x.fields)
+(x::TS, y::TS) = operation(x, y, +)
-(x::TS, y::TS) = operation(x, y, -)
*(x::TS, y::TS) = operation(x, y, *)
/(x::TS, y::TS) = operation(x, y, /)
.+(x::TS, y::TS) = operation(x, y, .+)
.-(x::TS, y::TS) = operation(x, y, .-)
.*(x::TS, y::TS) = operation(x, y, .*)
./(x::TS, y::TS) = operation(x, y, ./)
.\(x::TS, y::TS) = operation(x, y, .\)
.^(x::TS, y::TS) = operation(x, y, .^)
.%(x::TS, y::TS) = operation(x, y, .%)

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
+(y::AbstractArray, x::TS) = x + y
-(y::AbstractArray, x::TS) = x - y
*(y::AbstractArray, x::TS) = x * y
.+(y::AbstractArray, x::TS) = x .+ y
/(y::AbstractArray, x::TS) = x / y
.-(y::AbstractArray, x::TS) = x .- y
.*(y::AbstractArray, x::TS) = x .* y
./(y::AbstractArray, x::TS) = x ./ y
.%(y::AbstractArray, x::TS) = x .% y

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
+(y::Number, x::TS) = x + y
-(y::Number, x::TS) = x - y
*(y::Number, x::TS) = x * y
/(y::Number, x::TS) = x / y
.+(y::Number, x::TS) = x .+ y
.-(y::Number, x::TS) = x .- y
.*(y::Number, x::TS) = x .* y
./(y::Number, x::TS) = x ./ y
.%(y::Number, x::TS) = x .% y

# Logical operators
all(x::TS) = all(x.values)
any(x::TS) = any(x.values)
!(x::TS) = ts(!x.values, x.index, x.fields)
==(x::TS, y::TS) = x.values == y.values && x.index == y.index
!=(x::TS, y::TS) = !(x == y)

.==(x::TS, y::TS) = operation(x, y, .==)
.>(x::TS, y::TS) = operation(x, y, .>)
.<(x::TS, y::TS) = operation(x, y, .<)
.!=(x::TS, y::TS) = operation(x, y, .!=)
.<=(x::TS, y::TS) = operation(x, y, .<=)
.>=(x::TS, y::TS) = operation(x, y, .>=)

.==(x::TS, y::Number) = ts(x.values .== y, x.index, x.fields)
.>(x::TS, y::Number) = ts(x.values .> y, x.index, x.fields)
.<(x::TS, y::Number) = ts(x.values .< y, x.index, x.fields)
.!=(x::TS, y::Number) = ts(x.values .!= y, x.index, x.fields)
.<=(x::TS, y::Number) = ts(x.values .<= y, x.index, x.fields)
.>=(x::TS, y::Number) = ts(x.values .>= y, x.index, x.fields)
.==(y::Number, x::TS) = ts(x.values .== y, x.index, x.fields)
.>(y::Number, x::TS) = ts(x.values .> y, x.index, x.fields)
.<(y::Number, x::TS) = ts(x.values .< y, x.index, x.fields)
.!=(y::Number, x::TS) = ts(x.values .!= y, x.index, x.fields)
.<=(y::Number, x::TS) = ts(x.values .<= y, x.index, x.fields)
.>=(y::Number, x::TS) = ts(x.values .>= y, x.index, x.fields)

.==(x::TS, y::AbstractArray) = ts(x.values .== y, x.index, x.fields)
.>(x::TS, y::AbstractArray) = ts(x.values .> y, x.index, x.fields)
.<(x::TS, y::AbstractArray) = ts(x.values .< y, x.index, x.fields)
.!=(x::TS, y::AbstractArray) = ts(x.values .!= y, x.index, x.fields)
.<=(x::TS, y::AbstractArray) = ts(x.values .<= y, x.index, x.fields)
.>=(x::TS, y::AbstractArray) = ts(x.values .>= y, x.index, x.fields)
.==(y::AbstractArray, x::TS) = ts(x.values .== y, x.index, x.fields)
.>(y::AbstractArray, x::TS) = ts(x.values .> y, x.index, x.fields)
.<(y::AbstractArray, x::TS) = ts(x.values .< y, x.index, x.fields)
.!=(y::AbstractArray, x::TS) = ts(x.values .!= y, x.index, x.fields)
.<=(y::AbstractArray, x::TS) = ts(x.values .<= y, x.index, x.fields)
.>=(y::AbstractArray, x::TS) = ts(x.values .>= y, x.index, x.fields)

>(x::TS, y::TS) = x .> y
<(x::TS, y::TS) = x .< y
<=(x::TS, y::TS) = x .<= y
>=(x::TS, y::TS) = x .>= y
