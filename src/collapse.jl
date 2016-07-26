#TODO: add "expand" method to go from shorter to greater frequencies
#TODO: include functionality for filling the missing values (approx, locf, etc.)

# Date vector
mondays(t::AbstractArray{Date,1}) = dayofweek(t) .== Monday
tuesdays(t::AbstractArray{Date,1}) = dayofweek(t) .== Tuesday
wednesdays(t::AbstractArray{Date,1}) = dayofweek(t) .== Wednesday
thursdays(t::AbstractArray{Date,1}) = dayofweek(t) .== Thursday
fridays(t::AbstractArray{Date,1}) = dayofweek(t) .== Friday
saturdays(t::AbstractArray{Date,1}) = dayofweek(t) .== Saturday
sundays(t::AbstractArray{Date,1}) = dayofweek(t) .== Sunday
# DateTime vector
mondays(t::AbstractArray{DateTime,1}) = dayofweek(t) .== Monday
tuesdays(t::AbstractArray{DateTime,1}) = dayofweek(t) .== Tuesday
wednesdays(t::AbstractArray{DateTime,1}) = dayofweek(t) .== Wednesday
thursdays(t::AbstractArray{DateTime,1}) = dayofweek(t) .== Thursday
fridays(t::AbstractArray{DateTime,1}) = dayofweek(t) .== Friday
saturdays(t::AbstractArray{DateTime,1}) = dayofweek(t) .== Saturday
sundays(t::AbstractArray{DateTime,1}) = dayofweek(t) .== Sunday
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
function bow(t::AbstractArray{Date,1}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== firstdayofweek(t))
    else
        return BitArray{1}([0;diff(week(t)).!=0])
    end
end
function eow(t::AbstractArray{Date,1}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== lastdayofweek(t))
    else
        return BitArray{1}([diff(week(t)).!=0;0])
    end
end
function bom(t::AbstractArray{Date,1}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== firstdayofmonth(t))
    else
        return BitArray{1}([0;diff(month(t)).!=0])
    end
end
function eom(t::AbstractArray{Date,1}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== lastdayofmonth(t))
    else
        BitArray{1}([diff(month(t)).!=0;0])
    end
end
function boq(t::AbstractArray{Date,1}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== firstdayofquarter(t))
    else
        return BitArray{1}([0;diff(quarterofyear(t)).!=0])
    end
end
function eoq(t::AbstractArray{Date,1}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== lastdayofquarter(t))
    else
        return BitArray{1}([diff(quarterofyear(t)).!=0;0])
    end
end
function boy(t::AbstractArray{Date,1}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== firstdayofyear(t))
    else
        return BitArray{1}([0;diff(year(t)).!=0])
    end
end
function eoy(t::AbstractArray{Date,1}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== lastdayofyear(t))
    else
        return BitArray{1}([diff(year(t)).!=0;0])
    end
end
function bow(t::AbstractArray{DateTime,1}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== firstdayofweek(t))
    else
        return BitArray{1}([0;diff(week(t)).!=0])
    end
end
function eow(t::AbstractArray{DateTime,1}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== lastdayofweek(t))
    else
        return BitArray{1}([diff(week(t)).!=0;0])
    end
end
function bom(t::AbstractArray{DateTime,1}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== firstdayofmonth(t))
    else
        return BitArray{1}([0;diff(month(t)).!=0])
    end
end
function eom(t::AbstractArray{DateTime,1}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== lastdayofmonth(t))
    else
        BitArray{1}([diff(month(t)).!=0;0])
    end
end
function boq(t::AbstractArray{DateTime,1}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== firstdayofquarter(t))
    else
        return BitArray{1}([0;diff(quarterofyear(t)).!=0])
    end
end
function eoq(t::AbstractArray{DateTime,1}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== lastdayofquarter(t))
    else
        return BitArray{1}([diff(quarterofyear(t)).!=0;0])
    end
end
function boy(t::AbstractArray{DateTime,1}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== firstdayofyear(t))
    else
        return BitArray{1}([0;diff(year(t)).!=0])
    end
end
function eoy(t::AbstractArray{DateTime,1}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== lastdayofyear(t))
    else
        return BitArray{1}([diff(year(t)).!=0;0])
    end
end

bow(x::TS; cal::Bool=false) = x[bow(x.index, cal=cal)]
eow(x::TS; cal::Bool=false) = x[eow(x.index, cal=cal)]
bom(x::TS; cal::Bool=false) = x[bom(x.index, cal=cal)]
eom(x::TS; cal::Bool=false) = x[eom(x.index, cal=cal)]
boq(x::TS; cal::Bool=false) = x[boq(x.index, cal=cal)]
eoq(x::TS; cal::Bool=false) = x[eoq(x.index, cal=cal)]
boy(x::TS; cal::Bool=false) = x[boy(x.index, cal=cal)]
eoy(x::TS; cal::Bool=false) = x[eoy(x.index, cal=cal)]


function collapse{V,T}(x::TS{V,T}, at::AbstractArray{Bool,1}; fun::Function=last, args...)
    @assert size(at,1) == size(x,1) "Arguments `x` and `at` must have same number of rows."
    idx = find(at)
    if fun == last
        return x[idx]
    end
    out = zeros(V, (length(idx)-1, size(x,2)))
    a, b = (idx[1:end-1], idx[2:end])
    @inbounds for j=1:size(x,2), i=1:length(idx)-1
        out[i,j] = fun(x.values[a[i]:b[i], j]; args...)
    end
    at[idx[1]] = false
    return ts(out, x.index[at], x.fields)
end

# Here `at` is a function of the index of `x` which generates a BitArray to be used as above
function collapse{V,T}(x::TS{V,T}, at::Function; fun::Function=last, args...)
    return collapse(x, at(x.index), fun=fun; args...)
end

function apply{V}(x::TS{V}, dim::Int=1; fun=sum)
    if dim == 1
        n = size(x,1)
        out = zeros(V, n)
        @inbounds for i in 1:n
            out[i] = fun(x.values[i,:])
        end
        return ts(out, x.index, symbol(ucfirst(string(fun))))
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
