#=
Methods for slicing and dicing TS objects
=#

@doc """
Get the first `n` observations of a TS object
""" ->
head{V,T}(x::TS{V,T}, n::Int=5) = x[1:n,:]

@doc """
Get the last `n` observations of a TS object
""" ->
tail{V,T}(x::TS{V,T}, n::Int=5) = x[end-n+1:end,:]

@doc """
Get the indexes of all rows in an Array containing NaN values
""" ->
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

@doc """
Get the indexes of all columns in an Array containing NaN values
""" ->
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

nanrows{V,T}(x::TS{V,T}) = ts(nanrows(x.values), x.index, x.fields)
nancols(x::TS) = nancols(x.values)

@doc """
Drop missing (NaN) values from an Array
""" ->
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

@doc """
Drop missing (NaN) values from a TS object
""" ->
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

function ffill!{Float64}(x::AbstractArray{Float64,1})
	i = findfirst(!isnan(x))
	@inbounds for i = i+1:size(x,1)
		isnan(x[i]) ? x[i] = x[i-1] : nothing
	end
	return x
end

function ffill!{Float64}(x::AbstractArray{Float64,2})
	@inbounds for j = 1:size(x,2)
		x[:,j] = ffill!(x[:,j])
	end
end

function bfill!{Float64}(x::AbstractArray{Float64,1})
	i = findlast(!isnan(x))
	@inbounds for i = i-1:-1:1
		isnan(x[i]) ? x[i] = x[i+1] : nothing
	end
	return x
end

function bfill!{Float64}(x::AbstractArray{Float64,2})
	@inbounds for j = 1:size(x,2)
		x[:,j] = bfill!(x[:,j])
	end
end

function interpolate(x1::Int, x2::Int, y1::Float64, y2::Float64)
	m = (y2-y1)/(x2-x1)
	b = y1 - m*x1
	x = collect(x1:1.0:x2)
	y = m*x + b
	return y
end

function linterp!{Float64}(x::AbstractArray{Float64,1})
	@assert size(x,1) > 3 "Must have 3 or more elements to interpolate."
	isval = !isnan(x)
	if all(isval)
		return x
	end
	@assert sum(isval) > 2 "Must have at least 2 non-missing values to interpolate."
	idx = find(isval)
	a = idx[1]
	b = idx[2]
	@inbounds for i = 2:size(idx,1)
		x[a:b] = interpolate(a, b, x[a], x[b])
		a = b
		b = idx[i+1]
	end
	return x
end

function linterp!{Float64}(x::AbstractArray{Float64,2})
	@inbounds for j = 1:size(x,2)
		x[:,j] = linterp!(x[:,j])
	end
end

# TODO: make this more efficient (learn how to assign and not mutate)
@doc """
Fill missing (NaN) values from a TS object
""" ->
function fillnan{V,T}(x::TS{V,T}, method::Symbol=:ffill)
	c = nancols(x.values)
	if !any(c)
		return x
	end
	v = copy(x.values)
	if method == :ffill
		ffill!(v)
	elseif method == :bfill
		bfill!(v)
	elseif method == :linear
		@inbounds for j = find(c)
			linterp!(v)
		end
	#TODO: elseif method == :spline
	else
		error("Invalid method argument: Must be `:ffill`, `:bfill`, `:linear`, or `:spline`.")
	end
	return ts(v, x.index, x.fields)
end

@doc """
Replace missing (NaN) values from a TS object with filled values.
""" ->
function fillnan!{V,T}(x::TS{V,T}, method::Symbol=:ffill)
    c = nancols(x.values)
    if !any(c)
        return x
    end
    v = x.values
    if method == :ffill
        ffill!(v)
    elseif method == :bfill
        bfill!(v)
    elseif method == :linear
        linterp!(v)
    # elseif method == :spline
    end
    return ts(v, x.index, x.fields)
end

