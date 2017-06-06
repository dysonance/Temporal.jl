#=
Utilities for combining and manipulating TS objects using their indexes
=#

import Base: hcat, vcat, merge

function overlaps(x::AbstractArray, y::AbstractArray, n::Int=1)::Vector{Bool}
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

# function partner(x::TS, y::TS)
#     yy = !overlaps(x.index, y.index) .* NaN
#     yy[!isnan(yy),:] = y.values
#     return ts(yy, x.index, y.fields)
# end

@doc """
Outer join two TS objects by index.

Equivalent to `x` OUTER JOIN `y` ON `x.index` = `y.index`.

`ojoin(x::TS, y::TS)::TS`
""" ->
function ojoin(x::TS, y::TS)::TS
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

@doc """
Inner join two TS objects by index.

Equivalent to `x` INNER JOIN `y` on `x.index` = `y.index`.

`ijoin(x::TS, y::TS)::TS`
""" ->
function ijoin(x::TS, y::TS)::TS
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

@doc """
Left join two TS objects by index.

Equivalent to `x` LEFT JOIN `y` ON `x.index` = `y.index`.

`ljoin(x::TS, y::TS)::TS`
""" ->
function ljoin(x::TS, y::TS)::TS
    return [x y[intersect(x.index, y.index)]]
end

@doc """
Right join two TS objects by index.

Equivalent to `x` RIGHT JOIN `y` ON `x.index` = `y.index`.

`rjoin(x::TS, y::TS)::TS`
""" ->
function rjoin(x::TS, y::TS)::TS
    return [x[intersect(x.index, y.index)] y]
end

# ljoin(x::TS, y::TS) = ts([x.values partner(x,y).values], x.index, [x.fields; y.fields])
# rjoin(x::TS, y::TS) = ts([partner(y,x).values y.values], y.index, [x.fields; y.fields])

hcat(x::TS, y::TS)::TS = ojoin(x, y)
hcat(x::TS)::TS = x
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

@doc """
Merge two TS objects by index.

The `join` argument specifies the logic used to perform the merge, and may take on the values 'o' (outer join), 'i' (inner join), 'l' (left join), or 'r' (right join). Defaults to outer join, whose result is the same as `hcat(x, y)` or `[x y]`.

`merge(x::TS, y::TS; join::Char='o')::TS`
""" ->
function merge(x::TS, y::TS; join::Char='o')::TS
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
hcat(x::TS, y::AbstractArray)::TS = ojoin(x, ts(y, x.index))
hcat(y::AbstractArray, x::TS)::TS = ojoin(ts(y, x.index), x)
hcat(x::TS, y::Number)::TS = ojoin(x, ts(fill(y,size(x,1)), x.index))
hcat(y::Number, x::TS)::TS = ojoin(ts(fill(y,size(x,1)), x.index), x)
function hcat{V}(series::TS, arrs::AbstractArray{V}...)::TS
    n = size(series,1)
    k = length(arrs)
    out = zeros(V, (n,k))
    @inbounds for j in 1:k
        out[:,j] = arrs[j]
    end
    return [series out]
end
function hcat{V<:Number}(series::TS, nums::V...)::TS
    n = size(series,1)
    k = length(nums)
    out = zeros(V, (n,k))
    @inbounds for j in 1:k
        out[:,j] = fill(n, nums[j])
    end
    return [series out]
end
