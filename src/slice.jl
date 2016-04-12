#=
Methods for slicing and dicing TS objects
=#

function partner{V,T}(x::TS{V,T}, y::TS{V,T})
    yy = !overlaps(x.index, y.index) .* NaN
    yy[!isnan(yy),:] = y.values
    return ts(yy, x.index, y.fields)
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
