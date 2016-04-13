#=
Operations on TS objects
=#

import Base: ones, zeros, trues, falses, sum, mean, maximum, minimum, prod, cumsum, cumprod, diff
importall Base.Operators


ones(x::TS) = ts(ones(x.values), x.index, x.fields)
zeros(x::TS) = ts(zeros(x.values), x.index, x.fields)
trues(x::TS) = ts(trues(x.values), x.index, x.fields)
falses(x::TS) = ts(falses(x.values), x.index, x.fields)

# Number output expected from `fun`
function numfun(x::TS, fun::Function; args...)
	return fun(x.values; args...)
end
# Array output expected from `fun`
function arrfun(x::TS, fun::Function; args...)
	return ts(fun(x.values; args...), x.index, x.fields)
end
# Function to pass Array operators through to underlying TS values
function op{V,T}(x::TS{V,T}, y::TS{V,T}, fun::Function; args...)
    idx = intersect(x.index, y.index)
    return ts(fun(x[idx].values, y[idx].values; args...), idx, x.fields)
end

# Number functions
sum(x::TS; args...) = numfun(x, sum; args...)
mean(x::TS; args...) = numfun(x, mean; args...)
prod(x::TS; args...) = numfun(x, prod; args...)
maximum(x::TS; args...) = numfun(x, maximum; args...)
minimum(x::TS; args...) = numfun(x, minimum; args...)
cummin(x::TS; args...) = numfun(x, cummin; args...)
cummax(x::TS; args...) = numfun(x, cummax; args...)
# Array functions
cumprod(x::TS; args...) = arrfun(x, cumprod; args...)
cumsum(x::TS; args...) = arrfun(x, cumsum; args...)
function diff(x::TS, n::Int=1; nanpad::Bool=true)
	@assert n < size(x,1) "Argument `n` out of bounds."
	v = x.values
	out = zeros(v)
	out[1:n,:] = NaN
	@inbounds for i=n+1:size(v,1)
		out[i,:] = v[i,:] - v[i-n,:]
	end
	if nanpad
		return ts(out, x.index, x.fields)
	else
		r = !nanrows(out)
		return ts(out[r,:], x.index[r], x.fields)
	end
end
function lag(x::TS, n::Int=1; nanpad::Bool=true)
	@assert abs(n) < size(x,1) "Argument `n` out of bounds."
	if n == 0
		return x
	elseif n > 0
		out = zeros(x.values)
		out[1:n,:] = NaN
		out[n+1:end,:] = x.values[1:end-n,:]
	elseif n < 0
		out = zeros(x.values)
		out[end+n+1:end,:] = NaN
		out[1:end+n,:] = x.values[1-n:end,:]
	end
	if nanpad
		return ts(out, x.index, x.fields)
	else
		r = !nanrows(out)
		return ts(out[r,:], x.index[r], x.fields)
	end
end
function roc(x::TS, n::Int=1; nanpad::Bool=true)
	@assert n > 0 "Argument `n` must be positive."
	out = diff(x,n) ./ lag(x,n)
	if nanpad
		return out
	else
		return dropnan(out)
	end
end

# Artithmetic operators
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
