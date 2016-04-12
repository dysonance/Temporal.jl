#=
Utilities for combining and manipulating TS objects using their indexes
=#

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

function ljoin{V,T}(x::TS{V,T}, y::TS{V,T})
    idx = intersect(x.index, y.index)
    yna = setdiff(x.index, y.index)
    yi = sortperm(setdiff(y.index, yna))
    yvals = [y[idx].values; fill(NaN, (length(yna), size(y,2)))][yi,:]
    return ts([x.values yvals], x.index, [x.fields; y.fields])
end

function rjoin{V,T}(x::TS{V,T}, y::TS{V,T})
    idx = intersect(x.index, y.index)
    xna = setdiff(y.index, x.index)
    xi = sortperm(setdiff(x.index, xna))
    xvals = [x[idx].values; fill(NaN, (length(xna), size(x,2)))][xi,:]
    return ts([xvals y.values], y.index, [x.fields; y.fields])
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

function dropnan{V,T}(x::TS{V,T}; rows::Bool=true, cols::Bool=false, fun::Function=any)
    @assert fun == any || fun == all "`fun` must be either `any` or `all`"
    n, k = size(x)
    vals = x.values
    cutrows = falses(n)
    cutcols = falses(k)
    if rows
        for i = 1:n
            cutrows[i] = fun(isnan(vals[i,:]))
        end
    end
    if cols
        for j = 1:k
            cutcols[j] = fun(isnan(vals[:,j]))
        end
    end
    return x[cutrows,cutcols]
end

function dropnil{V,T}(x::TS{V,T}; rows::Bool=true, cols::Bool=false, fun::Function=any)
    @assert fun == any || fun == all "`fun` must be either `any` or `all`"
    n, k = size(x)
    vals = x.values
    cutrows = falses(n)
    cutcols = falses(k)
    if rows
        for i = 1:n
            cutrows[i] = fun(vals[i,:] .== 0.0)
        end
    end
    if cols
        for j = 1:k
            cutcols[j] = fun(vals[:,j] .== 0.0)
        end
    end
    return x[cutrows,cutcols]
end
