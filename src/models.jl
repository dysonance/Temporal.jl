# Autocorrelation
function corlag{T<:Number}(x::AbstractArray{T,1}, n::Int=1)
    if n == 0
        return 1.0
    end
    @assert n > 0
    @assert n < size(x,1)
    return cor(x[1:end-n], x[(n+1):end])
end

@doc """
Compute the autocorrelation function of a univariate time series

`acf{T<:Number}(x::AbstractArray{T,1}, maxlag::Int=15; lags::AbstractArray{Int,1}=0:maxlag)`
""" ->
function acf{T<:Number}(x::Vector{T}, maxlag::Int=15; lags::AbstractArray{Int,1}=0:maxlag)::Vector{Float64}
    @assert all(lags .< size(x,1)-1)
    return map((n) -> corlag(x, n), lags)
end
acf(x::TS, maxlag::Int=15; lags::AbstractArray{Int,1}=0:maxlag)::Vector{Float64} = acf(x.values, maxlag; lags=lags)

function acf{T<:Number}(x::Matrix{T}, maxlag::Int=15; lags::AbstractVector{Int}=0:maxlag)::Matrix{Float64}
    k = size(x,2)
    out = zeros(Float64, (length(lags), k))
    @inbounds for j in 1:k
        out[:,j] = acf(x[:,j], maxlag, lags=lags)
    end
    return out
end

acf(x::TS, maxlag::Int=15; lags::AbstractArray{Int,1}=0:maxlag) = acf(x.values, maxlag; lags=lags)

