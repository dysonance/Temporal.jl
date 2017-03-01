#=
Utilities for combining and manipulating TS objects using their indexes
=#

import Base: hcat, vcat, merge

function overlaps(x::AbstractArray, y::AbstractArray, n::Int=1)
    if n == 1
        xx = falses(x)
        @inbounds for i = 1:size(x,1), j = 1:size(y,1)
            if x[i] == y[j]
                xx[i] = true
            end
        end
        return xx
    elseif n == 2
        yy = falses(y)
        @inbounds for i = 1:size(x,1), j = 1:size(y,1)
            if x[i] == y[j]
                yy[i] = true
            end
        end
        return yy
    else
        error("Argument `n` must be either 1 (x) or 2 (y).")
    end
end

function partner(x::TS, y::TS)
    yy = !overlaps(x.index, y.index) .* NaN
    yy[!isnan(yy),:] = y.values
    return ts(yy, x.index, y.fields)
end

function ojoin(x::TS, y::TS)
    if isempty(x) && !isempty(y)
        return y
    elseif isempty(y) && !isempty(x)
        return x
    elseif isempty(x) && isempty(y)
        return ts()
    end
    idx = union(x.index, y.index)
    xna = setdiff(idx, x.index)
    yna = setdiff(idx, y.index)
    xi = sortperm([x.index; xna])
    yi = sortperm([y.index; yna])
    xvals = [x.values; fill(NaN, (length(xna), size(x,2)))][xi,:]
    yvals = [y.values; fill(NaN, (length(yna), size(y,2)))][yi,:]
    return ts([xvals yvals], sort(idx), [x.fields; y.fields])
end

function ijoin(x::TS, y::TS)
    if isempty(x) && !isempty(y)
        return y
    elseif isempty(y) && !isempty(x)
        return x
    elseif isempty(x) && isempty(y)
        return ts()
    end
    idx = intersect(x.index, y.index)
    return ts([x[idx].values y[idx].values], idx, [x.fields; y.fields])
end

ljoin(x::TS, y::TS) = ts([x.values partner(x,y).values], x.index, [x.fields; y.fields])
rjoin(x::TS, y::TS) = ts([partner(y,x).values y.values], y.index, [x.fields; y.fields])
hcat(x::TS, y::TS) = ojoin(x, y)
hcat(x::TS) = x
function hcat(series::TS...)
    out = series[1]
    @inbounds for j = 2:length(series)
        out = [out series[j]]
    end
    return out
end
function vcat(x::TS, y::TS)
    @assert size(x,2) == size(y,2) "Dimension mismatch: Number of columns must be equal."
    return TS([x.values;y.values], [x.index;y.index], x.fields)
end
function vcat(series::TS...)
    out = series[1]
    @inbounds for j = 2:length(series)
        out = vcat(out, series[j])
    end
    return out
end

function merge(x::TS, y::TS; join::Char='o')
    @assert join == 'o' || join == 'i' || join == 'l' || join == 'r' "`join` must be 'o', 'i', 'l', or 'r'."
    if join == 'o'
        return ojoin(x, y)
    elseif join == 'i'
        return ijoin(x, y)
    elseif join == 'l'
        return ljoin(x, y)
    elseif join == 'r'
        return rjoin(x, y)
    end
end

#===============================================================================
                COMBINING/MERGING WITH OTHER TYPES
===============================================================================#
hcat(x::TS, y::AbstractArray) = ojoin(x, ts(y, x.index))
hcat(y::AbstractArray, x::TS) = ojoin(ts(y, x.index), x)
hcat(x::TS, y::Number) = ojoin(x, ts(fill(y,size(x,1)), x.index))
hcat(y::Number, x::TS) = ojoin(ts(fill(y,size(x,1)), x.index), x)
function hcat{V}(series::TS, arrs::AbstractArray{V}...)
    n = size(series,1)
    k = length(arrs)
    out = zeros(V, (n,k))
    @inbounds for j = 1:k
        out[:,j] = arrs[j]
    end
    return [series out]
end
function hcat{V<:Number}(series::TS, nums::V...)
    n = size(series,1)
    k = length(nums)
    out = zeros(V, (n,k))
    @inbounds for j = 1:k
        out[:,j] = fill(n, nums[j])
    end
    return [series out]
end
