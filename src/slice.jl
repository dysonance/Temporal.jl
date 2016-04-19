#=
Methods for slicing and dicing TS objects
=#

function partner{V,T}(x::TS{V,T}, y::TS{V,T})
    yy = !overlaps(x.index, y.index) .* NaN
    yy[!isnan(yy),:] = y.values
    return ts(yy, x.index, y.fields)
end

function nanrows(x::Array{Float64}; fun::Function=any)
	@assert fun == any || fun == all "Argument `fun` must be either `any` or `all`"
	cutrows = falses(size(x,1))
	@inbounds for i = 1:size(x,1)
		if fun(isnan(x[i,:]))
			cutrows[i] = true
		end
	end
	return cutrows
end

function nancols(x::Array{Float64}; fun::Function=any)
	@assert fun == any || fun == all "Argument `fun` must be either `any` or `all`"
	cutcols = falses(size(x,2))
	@inbounds for j = 1:size(x,2)
		if fun(isnan(x[:,j]))
			cutcols[j] = true
		end
	end
	return cutcols
end

nanrows(x::TS) = nanrows(x.values)
nancols(x::TS) = nancols(x.values)

function dropnan(x::Array{Float64}; dim::Int=1, fun::Function=any)
	@assert dim == 1 || dim == 2 || dim == 3 "Argument `dim` must be 1 (rows), 2 (cols), or 3 (both)."
	if dim == 1  # rows only
		return x[!nanrows(x, fun=fun),:]
	elseif dim == 2  # columns only
		return x[:,!nancols(x, fun=fun)]
	elseif dim == 3  # rows and columns
		c = !nancols(x, fun=fun)
		return x[!nanrows(x[:,c], fun=fun),:]
	end
end

function dropnan{V,T}(x::TS{V,T}; dim::Int=1, fun::Function=any)
	@assert dim == 1 || dim == 2 || dim == 3 "Argument `dim` must be 1 (rows), 2 (columns), or 3 (both)."
	if dim == 1
		return x[!nanrows(x.values, fun=fun)]
	elseif dim == 2
		return x[:,!nancols(x.values, fun=fun)]
	elseif dim == 3
		return x[!nanrows(x.values, fun=fun), !nancols(x.values, fun=fun)]
	end
end

