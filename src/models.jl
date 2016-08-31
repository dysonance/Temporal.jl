@doc """
acf{T<:Number}(x::AbstractArray{T,1}, n::Int=1)

Compute the autocorrelation function of a univariate time series
""" ->
function acf{T<:Number}(x::AbstractArray{T,1}, n::Int=1)
    if n == 0
        return 1.0
    end
    @assert n >= 0
    @assert n < size(x,1)
    return cor(x[1:end-n], x[(n+1):end])
end
function acf{T<:Number}(x::AbstractArray{T,1}, n::AbstractArray{Int,1}=0:30)
    @assert length(n) < size(x,1)
    return map((n) -> acf(x, n), n)
end

acf(x::TS, n::Int=1) = acf(x.values, n)
acf(x::TS, n::AbstractArray{Int,1}=0:30) = acf(x.values, n)
