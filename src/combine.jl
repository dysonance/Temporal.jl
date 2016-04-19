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

function partner{V,T}(x::TS{V,T}, y::TS{V,T})
    yy = !overlaps(x.index, y.index) .* NaN
    yy[!isnan(yy),:] = y.values
    return ts(yy, x.index, y.fields)
end

function ojoin{V,T}(x::TS{V,T}, y::TS{V,T})
    idx = union(x.index, y.index)
    xna = setdiff(idx, x.index)
    yna = setdiff(idx, y.index)
    xi = sortperm([x.index; xna])
    yi = sortperm([y.index; yna])
    xvals = [x.values; fill(NaN, (length(xna), size(x,2)))][xi,:]
    yvals = [y.values; fill(NaN, (length(yna), size(y,2)))][yi,:]
    return ts([xvals yvals], idx, [x.fields; y.fields])
end

function ijoin{V,T}(x::TS{V,T}, y::TS{V,T})
    idx = intersect(x.index, y.index)
    return ts([x[idx].values y[idx].values], idx, [x.fields; y.fields])
end

ljoin{V,T}(x::TS{V,T}, y::TS{V,T}) = ts([x.values partner(x,y).values], x.index, [x.fields; y.fields])
rjoin{V,T}(x::TS{V,T}, y::TS{V,T}) = ts([partner(y,x).values y.values], y.index, [x.fields; y.fields])
hcat{V,T}(x::TS{V,T}, y::TS{V,T}) = ojoin(x, y)
function hcat{V,T}(series::TS{V,T}...)
    out = series[1]
    for j = 2:length(series)
        out = ojoin(out, series[j])
    end
    return out
end
function vcat{V,T}(x::TS{V,T}, y::TS{V,T})
    @assert size(x,2) == size(y,2) "Dimension mismatch: Number of columns must be equal."
    return TS{V,T}([x.values;y.values], [x.index;y.index], x.fields)
end
function vcat{V,T}(series::TS{V,T}...)
    out = series[1]
    for j = 2:length(series)
        out = vcat(out, series[j])
    end
    return out
end

function merge{V,T}(x::TS{V,T}, y::TS{V,T}; join::Char='o')
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

