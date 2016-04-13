#=
Methods for aggregating/collapsing TS objects
=#

frequency(t::Vector{Date}) = Day(median(Vector{Int}(diff(t))))
frequency(t::Vector{DateTime}) = Millisecond(median(Vector{Int}(diff(t))))
frequency(x::TS) = frequency(x.index)

isweekday(t::Vector{Date}, wd::Int) = BitArray{1}(dayofweek(t) .== wd)
isweekday(t::Vector{DateTime}, wd::Int) = BitArray{1}(dayofweek(t) .== wd)
isweekday(x::TS, wd::Int) = x[isweekday(x.index, wd)]
mondays(x::TS) = isweekday(x, Monday)
tuesdays(x::TS) = isweekday(x, Tuesday)
wednesdays(x::TS) = isweekday(x, Wednesday)
thursdays(x::TS) = isweekday(x, Thursday)
fridays(x::TS) = isweekday(x, Friday)
saturdays(x::TS) = isweekday(x, Saturday)
sundays(x::TS) = isweekday(x, Sunday)


# If `cal` is true, only returns observations on the last calendar day of the month.
# If `cal` is false, returns all observations for which the next index is a new month.
function bow(t::Vector{Date}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== firstdayofweek(t))
    else
        return BitArray{1}([0;diff(week(t)).!=0])
    end
end
function eow(t::Vector{Date}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== lastdayofweek(t))
    else
        return BitArray{1}([diff(week(t)).!=0;0])
    end
end
function bom(t::Vector{Date}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== firstdayofmonth(t))
    else
        return BitArray{1}([0;diff(month(t)).!=0])
    end
end
function eom(t::Vector{Date}, cal::Bool=false)
    if cal
        return BitArray{1}(t .== lastdayofmonth(t))
    else
        BitArray{1}([diff(month(t)).!=0;0])
    end
end
function boq(t::Vector{Date}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== firstdayofquarter(t))
    else
        return BitArray{1}([0;diff(quarterofyear(t)).!=0])
    end
end
function eoq(t::Vector{Date}, cal::Bool=false)
    if cal
        return BitArray{1}(t .== lastdayofquarter(t))
    else
        return BitArray{1}([diff(quarterofyear(t)).!=0;0])
    end
end
function boy(t::Vector{Date}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== firstdayofyear(t))
    else
        return BitArray{1}([0;diff(year(t)).!=0])
    end
end
function eoy(t::Vector{Date}, cal::Bool=false)
    if cal
        return BitArray{1}(t .== lastdayofyear(t))
    else
        return BitArray{1}([diff(year(t)).!=0;0])
    end
end
function bow(t::Vector{DateTime}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== firstdayofweek(t))
    else
        return BitArray{1}([0;diff(week(t)).!=0])
    end
end
function eow(t::Vector{DateTime}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== lastdayofweek(t))
    else
        return BitArray{1}([diff(week(t)).!=0;0])
    end
end
function bom(t::Vector{DateTime}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== firstdayofmonth(t))
    else
        return BitArray{1}([0;diff(month(t)).!=0])
    end
end
function eom(t::Vector{DateTime}, cal::Bool=false)
    if cal
        return BitArray{1}(t .== lastdayofmonth(t))
    else
        BitArray{1}([diff(month(t)).!=0;0])
    end
end
function boq(t::Vector{DateTime}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== firstdayofquarter(t))
    else
        return BitArray{1}([0;diff(quarterofyear(t)).!=0])
    end
end
function eoq(t::Vector{DateTime}, cal::Bool=false)
    if cal
        return BitArray{1}(t .== lastdayofquarter(t))
    else
        return BitArray{1}([diff(quarterofyear(t)).!=0;0])
    end
end
function boy(t::Vector{DateTime}; cal::Bool=false)
    if cal
        return BitArray{1}(t .== firstdayofyear(t))
    else
        return BitArray{1}([0;diff(year(t)).!=0])
    end
end
function eoy(t::Vector{DateTime}, cal::Bool=false)
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


function aggregate{V,T}(x::TS{V,T}, at::AbstractArray{Bool,1}; fun::Function=mean)
    @assert size(at,1) == size(x,1) "Arguments `x` and `at` must have same number of rows."
    idx = find(at)
    raw = x.values
    out = zeros(V, (length(idx)-1, size(x,2)))
    a, b = (idx[1:end-1], idx[2:end])
    @inbounds for j=1:size(x,2), i=1:length(idx)-1
        out[i,j] = fun(raw[a[i]:b[i], j])
    end
    at[idx[1]] = false
    return ts(out, x.index[at], x.fields)
end

