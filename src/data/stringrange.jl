import Base: ==, !=

const RANGE_DELIMITER = '/'
const DATE_STRING_LENGTHS = (4, 7, 10)
const DATETIME_STRING_LENGTHS = (4, 7, 10, 13, 16, 19)

function thrudt(s::AbstractString, t::Vector{Date})
    n = length(s)
    @assert n in DATE_STRING_LENGTHS "Invalid indexing string: Unable to parse $s"
    if n == 4  # yyyy given
        y = parse(Int, s)
        ymd = Date(y, 12, 31)
    elseif n == 7  # yyyy-mm given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        ymd = lastdayofmonth(Date(y, m, 1))
    elseif n == 10  # yyyy-mm-dd given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        d = parse(Int, a[3])
        ymd = Date(y, m, d)
    end
    return t .<= ymd
end

function fromdt(s::AbstractString, t::Vector{Date})
    n = length(s)
    @assert n in DATE_STRING_LENGTHS "Invalid indexing string: Unable to parse $s"
    if n == 4  # yyyy given
        y = parse(Int, s)
        ymd = Date(y, 1, 1)
    elseif n == 7  # yyyy-mm given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        ymd = Date(y, m, 1)
    elseif n == 10  # yyyy-mm-dd given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        d = parse(Int, a[3])
        ymd = Date(y, m, d)
    end
    return t .>= ymd
end

function thisdt(s::AbstractString, t::Vector{Date})
    n = length(s)
    @assert n in DATE_STRING_LENGTHS "Invalid indexing string: Unable to parse $s"
    if n == 4  # yyyy given
        y = parse(Int, s)
        return year.(t) .== y
    elseif n == 7  # yyyy-mm given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        return (year.(t) .== y) .& (month.(t) .== m)
    elseif n == 10  # yyyy-mm-dd given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        d = parse(Int, a[3])
        idx = (year.(t) .== y) .& (month.(t) .== m) .& (day.(t) .== d)
    end
end

function fromthru(from::AbstractString, thru::AbstractString, t::Vector{Date})
    fromidx = fromdt(from, t)
    thruidx = thrudt(thru, t)
    return fromidx .& thruidx
end

function thrudt(s::AbstractString, t::Vector{DateTime})
    n = length(s)
    @assert n in DATETIME_STRING_LENGTHS || n >= 20 "Invalid indexing string: Unable to parse $s"
    if n == 4  # yyyy given
        y = parse(Int, s)
        ymdhms = DateTime(y, 12, 31)
    elseif n == 7  # yyyy-mm given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        ymdhms = lastdayofmonth(DateTime(y, m, 1))
    elseif n == 10  # yyyy-mm-dd given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        d = parse(Int, a[3])
        ymdhms = DateTime(y, m, d)
    elseif n == 13  # yyyy-mm-ddTHH given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = 59
        sec = 59
        ymdhms = DateTime(y, m, d, hr, min, sec)
    elseif n == 16  # yyyy-mm-ddTHH:MM given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = parse(Int, c[2])
        sec = 59
        ymdhms = DateTime(y, m, d, hr, min, sec)
    elseif n == 19  # yyyy-mm-ddTHH:MM:SS given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = parse(Int, c[2])
        sec = parse(Int, c[3])
        ymdhms = DateTime(y, m, d, hr, min, sec)
    elseif n >= 20  # milliseconds given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        f = split(c[3], '.')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = parse(Int, c[2])
        sec = parse(Int, f[1])
        milli = parse(Int, f[2])
        ymdhms = DateTime(y, m, d, hr, min, sec, milli)
    end
    return t .<= ymdhms
end

function fromdt(s::AbstractString, t::Vector{DateTime})
    n = length(s)
    @assert n in DATETIME_STRING_LENGTHS || n >= 20 "Invalid indexing string: Unable to parse $s"
    if n == 4  # yyyy given
        y = parse(Int, s)
        ymdhms = DateTime(y)
    elseif n == 7  # yyyy-mm given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        ymdhms = DateTime(y, m)
    elseif n == 10  # yyyy-mm-dd given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        d = parse(Int, a[3])
        ymdhms = DateTime(y, m, d)
    elseif n == 13  # yyyy-mm-ddTHH given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        ymdhms = DateTime(y, m, d, hr)
    elseif n == 16  # yyyy-mm-ddTHH:MM given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = parse(Int, c[2])
        ymdhms = DateTime(y, m, d, hr, min)
    elseif n == 19  # yyyy-mm-ddTHH:MM:SS given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = parse(Int, c[2])
        sec = parse(Int, c[3])
        ymdhms = DateTime(y, m, d, hr, min, sec)
    elseif n >= 20  # milliseconds given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        f = split(c[3], '.')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = parse(Int, c[2])
        sec = parse(Int, f[1])
        milli = parse(Int, f[2])
        ymdhms = DateTime(y, m, d, hr, min, sec, milli)
    end
    return t .>= ymdhms
end

function thisdt(s::AbstractString, t::Vector{DateTime})
    n = length(s)
    if n == 4  # yyyy given
        y = parse(Int, s)
        return year.(t) .== y
    elseif n == 7  # yyyy-mm given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        return (year.(t) .== y) .& (month.(t) .== m)
    elseif n == 10  # yyyy-mm-dd given
        a = split(s, '-')
        y = parse(Int, a[1])
        m = parse(Int, a[2])
        d = parse(Int, a[3])
        return (year.(t) .== y) .& (month.(t) .== m) .& (day.(t) .== d)
    elseif n == 13  # yyyy-mm-ddTHH given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        return (year.(t) .== y) .& (month.(t) .== m) .& (day.(t) .== d) .& (hour.(t) .== hr)
    elseif n == 16  # yyyy-mm-ddTHH:MM given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = parse(Int, c[2])
        return (year.(t) .== y) .& (month.(t) .== m) .& (day.(t) .== d) .& (hour.(t) .== hr) .& (minute.(t) .== min)
    elseif n == 19  # yyyy-mm-ddTHH:MM:SS given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = parse(Int, c[2])
        sec = parse(Int, c[3])
        return (year.(t) .== y) .& (month.(t) .== m) .& (day.(t) .== d) .& (hour.(t) .== hr) .& (minute.(t) .== min) .& (second.(t) .== sec)
    elseif n >= 20  # milliseconds given
        a = split(s, 'T')
        b = split(a[1], '-')
        c = split(a[2], ':')
        f = split(c[3], '.')
        y = parse(Int, b[1])
        m = parse(Int, b[2])
        d = parse(Int, b[3])
        hr = parse(Int, c[1])
        min = parse(Int, c[2])
        sec = parse(Int, f[1])
        milli = parse(Int, f[2])
        return (year.(t) .== y) .& (month.(t) .== m) .& (day.(t) .== d) .& (hour.(t) .== hr) .& (minute.(t) .== min) .& (second.(t) .== sec) .& (millisecond.(t) .== milli)
    end
end

function fromthru(from::AbstractString, thru::AbstractString, t::Vector{DateTime})
    fromidx = fromdt(from, t)
    thruidx = thrudt(thru, t)
    return fromidx .& thruidx
end

function dtidx(s::AbstractString, t::Vector{Date})
    if s == "/" || s == ""
        return trues(length(t))
    end
    @assert !in('T', s) "Cannot index Date type with sub-daily frequency."
    bds = split(s, RANGE_DELIMITER)
    @assert length(bds) in [1,2]
    if length(bds) == 1  # single date
        return thisdt(s, t)
    elseif length(bds) == 2  # date range
        n1 = length(bds[1])
        n2 = length(bds[2])
        if n1 == 0 && n2 != 0  # thru date given
            return thrudt(bds[2], t)
        elseif n1 != 0 && n2 == 0  # from date given
            return fromdt(bds[1], t)
        elseif n1 != 0 && n2 != 0  # from and thru date given
            return fromthru(bds[1], bds[2], t)
        end
    end
end

function dtidx(s::AbstractString, t::Vector{DateTime})
    if s == "/" || s == ""
        return trues(length(t))
    end
    bds = split(s, RANGE_DELIMITER)
    @assert length(bds) in [1,2]
    if length(bds) == 1  # single date
        return thisdt(s, t)
    elseif length(bds) == 2  # date range
        n1 = length(bds[1])
        n2 = length(bds[2])
        if n1 == 0 && n2 != 0  # thru date given
            return thrudt(bds[2], t)
        elseif n1 != 0 && n2 == 0  # from date given
            return fromdt(bds[1], t)
        elseif n1 != 0 && n2 != 0  # from and thru date given
            return fromthru(bds[1], bds[2], t)
        end
    end
end
