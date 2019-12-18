# common operations specific to time series data structures: lagging/shifting, differencing, etc.

import Base: diff

function rowdx!(dx::A, x::A, n::Int, r::Int=size(x,1)) where {A<:AbstractArray}
    idx = n > 0 ? (n+1:r) : (1:r+n)
    @inbounds for i=idx
        dx[i,:] .= x[i,:] - x[i-n,:]
    end
    nothing
end

function coldx!(dx::A, x::A, n::Int, c::Int=size(x,2)) where {A<:AbstractArray}
    idx = n > 0 ? (n+1:c) : (1:c+n)
    @inbounds for j=idx
        dx[:,j] .= x[:,j] - x[:,j-n]
    end
    nothing
end

function diffn(x::A, dim::Int=1, n::Int=1) where {A<:AbstractArray}
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

function diff(x::TS{V}, n::Int=1; dim::Int=1, pad::Bool=false, padval::V=zero(eltype(x))) where {V}
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

function lag(x::TS{V}, n::Int=1; pad::Bool=false, padval::V=zero(eltype(x))) where {V}
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

function pct_change(x::TS{V}, n::Int=1; continuous::Bool=true, pad::Bool=false, padval::V=zero(eltype(x))) where {V}
    if continuous
        return diff(log.(x), n; pad=pad, padval=padval)
    else
        if pad
            return diff(x, n, pad=pad, padval=padval) / x
        else
            return diff(x, n) / x[n+1:end,:]
        end
    end
end

