#=
Methods for aggregating/collapsing TS objects
=#

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

iseom(t::Vector{Date}) = BitArray{1}(t .== lastdayofmonth(t))
iseom(t::Vector{DateTime}) = BitArray{1}(t .== lastdayofmonth(t))
iseom(x::TS) = x[iseom(x.index)]

@doc doc"""
monthends(x::TS, cal::Bool=false)

Get the observations occurring at each month end.

If `cal` is true, only returns observations on the last calendar day of the month.
If `cal` is false, returns all observations for which the next index is a new month.
""" ->
function monthends(x::TS, cal::Bool=false)
    if cal
        idx = BitArray{1}(iseom(x.index))
    else
        idx = BitArray{1}([diff(month(x.index)).!=0;0])
    end
    return x[idx]
end
