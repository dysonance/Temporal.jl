#TODO: add "expand" method to go from shorter to greater frequencies
#TODO: include functionality for filling the missing values (approx, locf, etc.)

# Date vector

mondays(t::AbstractArray{Date,1}) = dayofweek.(t) .== Monday
tuesdays(t::AbstractArray{Date,1}) = dayofweek.(t) .== Tuesday
wednesdays(t::AbstractArray{Date,1}) = dayofweek.(t) .== Wednesday
thursdays(t::AbstractArray{Date,1}) = dayofweek.(t) .== Thursday
fridays(t::AbstractArray{Date,1}) = dayofweek.(t) .== Friday
saturdays(t::AbstractArray{Date,1}) = dayofweek.(t) .== Saturday
sundays(t::AbstractArray{Date,1}) = dayofweek.(t) .== Sunday
# DateTime vector
mondays(t::AbstractArray{DateTime,1}) = dayofweek.(t) .== Monday
tuesdays(t::AbstractArray{DateTime,1}) = dayofweek.(t) .== Tuesday
wednesdays(t::AbstractArray{DateTime,1}) = dayofweek.(t) .== Wednesday
thursdays(t::AbstractArray{DateTime,1}) = dayofweek.(t) .== Thursday
fridays(t::AbstractArray{DateTime,1}) = dayofweek.(t) .== Friday
saturdays(t::AbstractArray{DateTime,1}) = dayofweek.(t) .== Saturday
sundays(t::AbstractArray{DateTime,1}) = dayofweek.(t) .== Sunday

# Time series input

"""
    mondays(x::TS)

Return a time series containing all observations occuring on Mondays of the given `TS` object.
"""
mondays(x::TS) = x[mondays(x.index)]

"""
    tuesdays(x::TS)

Return a time series containing all observations occuring on Tuesdays of the given `TS` object.
"""
tuesdays(x::TS) = x[tuesdays(x.index)]

"""
    wednesdays(x::TS)

Return a time series containing all observations occuring on Wednesdays of the given `TS` object.
"""
wednesdays(x::TS) = x[wednesdays(x.index)]

"""
    thursdays(x::TS)

Return a time series containing all observations occuring on Thursdays of the given `TS` object.
"""
thursdays(x::TS) = x[thursdays(x.index)]

"""
    fridays(x::TS)

Return a time series containing all observations occuring on Fridays of the given `TS` object.
"""
fridays(x::TS) = x[fridays(x.index)]

"""
    saturdays(x::TS)

Return a time series containing all observations occuring on Saturdays of the given `TS` object.
"""
saturdays(x::TS) = x[saturdays(x.index)]

"""
    sundays(x::TS)

Return a time series containing all observations occuring on Sundays of the given `TS` object.
"""
sundays(x::TS) = x[sundays(x.index)]


# If `cal` is true, only returns observations on the last calendar day of the month.
# If `cal` is false, returns all observations for which the next index is a new month.
bow(t::AbstractArray{T,1}; cal::Bool=false) where {T<:TimeType} = cal ? BitVector(t .== firstdayofweek.(t)) : BitVector([0;diff(week.(t)).!=0])
eow(t::AbstractArray{T,1}; cal::Bool=false) where {T<:TimeType} = cal ? BitVector(t .== lastdayofweek.(t)) : BitVector([diff(week.(t)).!=0;0])
bom(t::AbstractArray{T,1}; cal::Bool=false) where {T<:TimeType} = cal ? BitVector(t .== firstdayofmonth.(t)) : BitVector([0;diff(month.(t)).!=0])
eom(t::AbstractArray{T,1}; cal::Bool=false) where {T<:TimeType} = cal ? BitVector(t .== lastdayofmonth.(t)) : BitVector([diff(month.(t)).!=0;0])
boq(t::AbstractArray{T,1}; cal::Bool=false) where {T<:TimeType} = cal ? BitVector(t .== firstdayofquarter.(t)) : BitVector([0;diff(quarterofyear.(t)).!=0])
eoq(t::AbstractArray{T,1}; cal::Bool=false) where {T<:TimeType} = cal ? BitVector(t .== lastdayofquarter(t)) : BitVector([diff(quarterofyear.(t)).!=0;0])
boy(t::AbstractArray{T,1}; cal::Bool=false) where {T<:TimeType} = cal ? BitVector(t .== firstdayofyear.(t)) : BitVector([0;diff(year.(t)).!=0])
eoy(t::AbstractArray{T,1}; cal::Bool=false) where {T<:TimeType} = cal ? BitVector(t .== lastdayofyear.(t)) : BitVector([diff(year.(t)).!=0;0])

"""
    bow(x::TS; cal::Bool=false)

Return a time series containing all observations occuring at the beginnings of the weeks of the input.

- If `cal` is `false`, only observations occurring the last calendar day of the week are returned
- If `cal` is `true`, all observation for which the previous index is a prior week are returned
"""
bow(x::TS; cal::Bool=false) = x[bow(x.index, cal=cal)]

"""
    eow(x::TS; cal::Bool=false)

Return a time series containing all observations occuring at the ends of the weeks of the input.

- If `cal` is `false`, only observations occurring the last calendar day of the week are returned
- If `cal` is `true`, all observation for which the next index is a new week are returned
"""
eow(x::TS; cal::Bool=false) = x[eow(x.index, cal=cal)]

"""
    bom(x::TS; cal::Bool=false)

Return a time series containing all observations occuring at the beginnings of the months of the input.

- If `cal` is `false`, only observations occurring the last calendar day of the month are returned
- If `cal` is `true`, all observation for which the previous index is a prior month are returned
"""
bom(x::TS; cal::Bool=false) = x[bom(x.index, cal=cal)]

"""
    eom(x::TS; cal::Bool=false)

Return a time series containing all observations occuring at the ends of the months of the input.

- If `cal` is `false`, only observations occurring the last calendar day of the month are returned
- If `cal` is `true`, all observation for which the next index is a new month are returned
"""
eom(x::TS; cal::Bool=false) = x[eom(x.index, cal=cal)]

"""
    boq(x::TS; cal::Bool=false)

Return a time series containing all observations occuring at the beginnings of the quarters of the input.

- If `cal` is `false`, only observations occurring the last calendar day of the quarter are returned
- If `cal` is `true`, all observation for which the previous index is a prior quarter are returned
"""
boq(x::TS; cal::Bool=false) = x[boq(x.index, cal=cal)]

"""
    eoq(x::TS; cal::Bool=false)

Return a time series containing all observations occuring at the ends of the quarters of the input.

- If `cal` is `false`, only observations occurring the last calendar day of the quarter are returned
- If `cal` is `true`, all observation for which the next index is a new quarter are returned
"""
eoq(x::TS; cal::Bool=false) = x[eoq(x.index, cal=cal)]

"""
    boy(x::TS; cal::Bool=false)

Return a time series containing all observations occuring at the beginnings of the years of the input.

- If `cal` is `false`, only observations occurring the last calendar day of the year are returned
- If `cal` is `true`, all observation for which the previous index is a prior year are returned
"""
boy(x::TS; cal::Bool=false) = x[boy(x.index, cal=cal)]

"""
    eoy(x::TS; cal::Bool=false)

Return a time series containing all observations occuring at the ends of the years of the input.

- If `cal` is `false`, only observations occurring the last calendar day of the year are returned
- If `cal` is `true`, all observation for which the next index is a new year are returned
"""
eoy(x::TS; cal::Bool=false) = x[eoy(x.index, cal=cal)]


function collapse(x::TS, at::AbstractArray{Bool,1}; fun::Function=last, args...)::TS
    @assert size(at,1) == size(x,1) "Arguments `x` and `at` must have same number of rows."
    idx = findall(at)
    if fun == last
        return x[idx]
    end
    out = zeros((length(idx), size(x,2)))
    @inbounds for j in 1:size(x,2)
        out[1,j] = fun(x.values[1:idx[1], j]; args...)
    end
    @inbounds for j=1:size(x,2), i=2:length(idx)
        a = idx[i-1] + 1
        b = idx[i]
        out[i,j] = fun(x.values[a:b, j]; args...)
    end
    return ts(out, x.index[at], x.fields)
end

"""
    collapse(x::TS, at::Function; fun::Function=last, args...)::TS

Compute the function `fun` over period boundaries defined by `at` (e.g. `eom`, `boq`, etc.) and returng a time series of the results.

Keyword arguments (`args...`) are passed to the function `fun`.
"""
function collapse(x::TS, at::Function; fun::Function=last, args...)::TS
    # Here `at` is a function of the index of `x` which generates a BitArray to be used as above
    return collapse(x, at(x.index), fun=fun; args...)
end

"""
    apply(x::TS, dim::Int=1; fun::Function=sum)

Apply function `fun` across dimension `dim` of a time series `x`.

- If `dim` is 1, then apply `fun` to each row of `x`, returning a time series (`TS`) object of the results
- If `dim` is 2, then apply `fun` to each column of `x`, returning an `Array` of the results
"""
function apply(x::TS, dim::Int=1; fun::Function=sum)
    @assert dim == 1 || dim == 2 "dimension must be either 1 (rows) or 2 (columns)"
    if dim == 1
        n = size(x,1)
        out = zeros(n)
        @inbounds for i in 1:n
            out[i] = fun(x.values[i,:])
        end
        return ts(out, x.index, Symbol(uppercasefirst(string(fun))))
    elseif dim == 2
        k = size(x,2)
        out = zeros(k)
        @inbounds for j in 1:k
            out[j] = fun(x.values[:,j])
        end
        return out'
    else
        error("Argument `dim` must be either 1 (rows) or 2 (columns).")
    end
end
