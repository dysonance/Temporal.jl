@doc """
acf{T<:Number}(x::AbstractArray{T,1}, n::Int=1)

Compute the autocorrelation function of a univariate time series
""" ->
function corlag{T<:Number}(x::AbstractArray{T,1}, n::Int=1)
    if n == 0
        return 1.0
    end
    @assert n > 0
    @assert n < size(x,1)
    return cor(x[1:end-n], x[(n+1):end])
end
function acf{T<:Number}(x::AbstractArray{T,1}, maxlag::Int=15; lags::AbstractArray{Int,1}=0:maxlag)
    @assert all(lags .< size(x,1)-1)
    return map((n) -> corlag(x, n), lags)
end

acf(x::TS, maxlag::Int=15; lags::AbstractArray{Int,1}=0:maxlag) = acf(x.values, maxlag; lags=lags)
