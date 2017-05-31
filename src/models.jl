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

# Linear Models
# abstract TS_Model
# 
# type AR_Model <: TS_Model
#     data::TS
#     p::Int
# end
# 
# depvar(mod::AR_Model)::Vector = mod.data.values[1+mod.p:end]
# indvar(mod::AR_Model)::Matrix = [ones(size(mod.data,1)-mod.p) mod.data.values[1:end-mod.p,:]]
# function fit(mod::AR_Model)::Vector
#     @assert size(mod.data,2) == 1
#     y = depvar(mod)
#     X = indvar(mod)
#     β = (inv(X'X) * X' * y)[:,1]
#     return β
# end
# function fitted_values(mod::AR_Model)::Vector{Float64}
#     X = indvar(mod)
#     β = fit(mod)
#     return X*β
# end
# resid(mod::AR_Model)::Vector = depvar(mod) - fitted_values(mod)
# 
# type MA_Model <: TS_Model end
# 
# type ARMA_Model <: TS_Model end
# 
# type ARIMA_Model <: TS_Model end
# 
# type VAR_Model <: TS_Model end
# 
# type ARCH_Model <: TS_Model end
# 
# type GARCH_Model <: TS_Model end

# Stationarity Measures

