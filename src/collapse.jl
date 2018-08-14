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
mondays(x::TS) = x[mondays(x.index)]
tuesdays(x::TS) = x[tuesdays(x.index)]
wednesdays(x::TS) = x[wednesdays(x.index)]
thursdays(x::TS) = x[thursdays(x.index)]
fridays(x::TS) = x[fridays(x.index)]
saturdays(x::TS) = x[saturdays(x.index)]
sundays(x::TS) = x[sundays(x.index)]


# If `cal` is true, only returns observations on the last calendar day of the month.
# If `cal` is false, returns all observations for which the next index is a new month.
bow(t::AbstractArray{Date,1}; cal::Bool=false) = cal ? BitVector(t .== firstdayofweek.(t)) : BitVector([0;diff(week.(t)).!=0])
eow(t::AbstractArray{Date,1}; cal::Bool=false) = cal ? BitVector(t .== lastdayofweek.(t)) : BitVector([diff(week.(t)).!=0;0])
bom(t::AbstractArray{Date,1}; cal::Bool=false) = cal ? BitVector(t .== firstdayofmonth.(t)) : BitVector([0;diff(month.(t)).!=0])
eom(t::AbstractArray{Date,1}; cal::Bool=false) = cal ? BitVector(t .== lastdayofmonth.(t)) : BitVector([diff(month.(t)).!=0;0])
boq(t::AbstractArray{Date,1}; cal::Bool=false) = cal ? BitVector(t .== firstdayofquarter.(t)) : BitVector([0;diff(quarterofyear.(t)).!=0])
eoq(t::AbstractArray{Date,1}; cal::Bool=false) = cal ? BitVector(t .== lastdayofquarter(t)) : BitVector([diff(quarterofyear.(t)).!=0;0])
boy(t::AbstractArray{Date,1}; cal::Bool=false) = cal ? BitVector(t .== firstdayofyear.(t)) : BitVector([0;diff(year.(t)).!=0])
eoy(t::AbstractArray{Date,1}; cal::Bool=false) = cal ? BitVector(t .== lastdayofyear.(t)) : BitVector([diff(year.(t)).!=0;0])
bow(t::AbstractArray{DateTime,1}; cal::Bool=false) = cal ? BitVector(t .== firstdayofweek.(t)) : BitVector([0;diff(week.(t)).!=0])
eow(t::AbstractArray{DateTime,1}; cal::Bool=false) = cal ? BitVector(t .== lastdayofweek.(t)) : BitVector([diff(week.(t)).!=0;0])
bom(t::AbstractArray{DateTime,1}; cal::Bool=false) = cal ? BitVector(t .== firstdayofmonth.(t)) : BitVector([0;diff(month.(t)).!=0])
eom(t::AbstractArray{DateTime,1}; cal::Bool=false) = cal ? BitVector(t .== lastdayofmonth.(t)) : BitVector([diff(month.(t)).!=0;0])
boq(t::AbstractArray{DateTime,1}; cal::Bool=false) = cal ? BitVector(t .== firstdayofquarter.(t)) : BitVector([0;diff(quarterofyear.(t)).!=0])
eoq(t::AbstractArray{DateTime,1}; cal::Bool=false) = cal ? BitVector(t .== lastdayofquarter(t)) : BitVector([diff(quarterofyear.(t)).!=0;0])
boy(t::AbstractArray{DateTime,1}; cal::Bool=false) = cal ? BitVector(t .== firstdayofyear.(t)) : BitVector([0;diff(year.(t)).!=0])
eoy(t::AbstractArray{DateTime,1}; cal::Bool=false) = cal ? BitVector(t .== lastdayofyear.(t)) : BitVector([diff(year.(t)).!=0;0])

bow(x::TS; cal::Bool=false) = x[bow(x.index, cal=cal)]
eow(x::TS; cal::Bool=false) = x[eow(x.index, cal=cal)]
bom(x::TS; cal::Bool=false) = x[bom(x.index, cal=cal)]
eom(x::TS; cal::Bool=false) = x[eom(x.index, cal=cal)]
boq(x::TS; cal::Bool=false) = x[boq(x.index, cal=cal)]
eoq(x::TS; cal::Bool=false) = x[eoq(x.index, cal=cal)]
boy(x::TS; cal::Bool=false) = x[boy(x.index, cal=cal)]
eoy(x::TS; cal::Bool=false) = x[eoy(x.index, cal=cal)]


function collapse(x::TS{V,T}, at::AbstractArray{Bool,1}; fun::Function=last, args...)::TS{V,T} where {V,T}
    @assert size(at,1) == size(x,1) "Arguments `x` and `at` must have same number of rows."
    idx = findall(at)
    if fun == last
        return x[idx]
    end
    out = zeros(V, (length(idx), size(x,2)))
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

# Here `at` is a function of the index of `x` which generates a BitArray to be used as above
function collapse(x::TS{V,T}, at::Function; fun::Function=last, args...)::TS{V,T} where {V,T}
    return collapse(x, at(x.index), fun=fun; args...)
end

function apply(x::TS{V}, dim::Int=1; fun=sum) where {V}
    if dim == 1
        n = size(x,1)
        out = zeros(V, n)
        @inbounds for i in 1:n
            out[i] = fun(x.values[i,:])
        end
        return ts(out, x.index, Symbol(uppercasefirst(string(fun))))
    elseif dim == 2
        k = size(x,2)
        out = zeros(V, k)
        @inbounds for j in 1:k
            out[j] = fun(x.values[:,j])
        end
        return out'
    else
        error("Argument `dim` must be either 1 (rows) or 2 (columns).")
    end
end
