function overlaps(x::Vector, y::Vector)
    xx = falses(x)
    yy = falses(y)
    for i = 1:size(x,1), j = 1:size(y,1)
        if x[i] == y[j]
            xx[i] = true
            yy[j] = true
        end
    end
    return (xx, yy)
end
function overlaps(x::Vector, y::Vector, n::Int=1)
    if n == 1
        xx = falses(x)
        for i = 1:size(x,1), j = 1:size(y,1)
            if x[i] == y[j]
                xx[i] = true
            end
        end
        return xx
    elseif n == 2
        yy = falses(y)
        for i = 1:size(x,1), j = 1:size(y,1)
            if x[i] == y[j]
                yy[i] = true
            end
        end
        return yy
    else
        error("Argument `n` must be either 1 (x) or 2 (y).")
    end
end
#===============================================================================
							NUMERICAL INDEXING
===============================================================================#
getindex(x::TS) = x
getindex(x::TS, ::Colon) = x
getindex(x::TS, ::Colon, ::Colon) = x
getindex(x::TS, ::Colon, c::Int) = TS(x.values[:,c], x.index, [x.fields[c]])
getindex(x::TS, ::Colon, c::AbstractArray{Int,1}) = TS(x.values[:,c], x.index, x.fields[c])
getindex(x::TS, r::Int) = ts(x.values[r,:], x.index[r], x.fields)
getindex(x::TS, r::Int, ::Colon) = TS(x.values[r,:], [x.index[r]], x.fields)
getindex(x::TS, r::Int, c::Int) = TS([x.values[r,c]], [x.index[r]], [x.fields[c]])
getindex(x::TS, r::Int, c::AbstractArray{Int,1}) = TS(x.values[r,c], [x.index[r]], x.fields[c])
getindex(x::TS, r::AbstractArray{Int,1}) = ts(x.values[r,:], x.index[r], x.fields)
getindex(x::TS, r::AbstractArray{Int,1}, ::Colon) = TS(x.values[r,:], x.index[r], x.fields)
getindex(x::TS, r::AbstractArray{Int,1}, c::Int) = TS(x.values[r,c], x.index[r], [x.fields[c]])
getindex(x::TS, r::AbstractArray{Int,1}, c::AbstractArray{Int,1}) = TS(x.values[r, c], x.index[r], x.fields[c])

#===============================================================================
							TEMPORAL INDEXING
===============================================================================#
getindex(x::TS, t::TimeType) = x[find(map((r) -> r == t, x.index))]
getindex(x::TS, t::TimeType, ::Colon) = x[find(map((r) -> r == t, x.index)), :]
getindex(x::TS, t::TimeType, c::Int) = x[find(map((r) -> r == t, x.index)), c]
getindex(x::TS, t::TimeType, c::AbstractArray{Int,1}) = x[find(map((r) -> r == t, x.index)), c]
getindex(x::TS, t::AbstractArray{Date,1}) = x[find(map((r) -> r == t, x.index))]
getindex(x::TS, t::AbstractArray{Date,1}, ::Colon) = x[find(map((r) -> r == t, x.index)), :]
getindex(x::TS, t::AbstractArray{Date,1}, c::Int) = x[find(map((r) -> r == t, x.index)), c]
getindex(x::TS, t::AbstractArray{Date,1}, c::AbstractArray{Int,1}) = x[find(map((r) -> r == t, x.index)), c]
getindex(x::TS, t::AbstractArray{DateTime,1}) = x[find(map((r) -> r == t, x.index))]
getindex(x::TS, t::AbstractArray{DateTime,1}, ::Colon) = x[find(map((r) -> r == t, x.index)), :]
getindex(x::TS, t::AbstractArray{DateTime,1}, c::Int) = x[find(map((r) -> r == t, x.index)), c]
getindex(x::TS, t::AbstractArray{DateTime,1}, c::AbstractArray{Int,1}) = x[find(map((r) -> r == t, x.index)), c]

#===============================================================================
							TEXTUAL INDEXING
===============================================================================#
getindex(x::TS, ::Colon, c::ByteString) = x[r, find(x.fields .== c)]
getindex(x::TS, r::Int, c::ByteString) = x[r, find(x.fields .== c)]
getindex(x::TS, r::AbstractArray{Int,1}, c::ByteString) = x[r, find(x.fields .== c)]
getindex(x::TS, ::Colon, c::Vector{ByteString}) = x[:, find(overlaps(x.fields, c))]
getindex(x::TS, r::Int, c::Vector{ByteString}) = x[r, find(overlaps(x.fields, c))]
getindex(x::TS, r::AbstractArray{Int,1}, c::Vector{ByteString}) = x[r, find(overlaps(x.fields, c))]
getindex(x::TS, ::Colon, c::ASCIIString) = x[r, find(x.fields .== c)]
getindex(x::TS, r::Int, c::ASCIIString) = x[r, find(x.fields .== c)]
getindex(x::TS, r::AbstractArray{Int,1}, c::ASCIIString) = x[r, find(x.fields .== c)]
getindex(x::TS, ::Colon, c::Vector{ASCIIString}) = x[:, find(overlaps(x.fields, c))]
getindex(x::TS, r::Int, c::Vector{ASCIIString}) = x[r, find(overlaps(x.fields, c))]
getindex(x::TS, r::AbstractArray{Int,1}, c::Vector{ASCIIString}) = x[r, find(overlaps(x.fields, c))]
getindex(x::TS, ::Colon, c::UTF8String) = x[r, find(x.fields .== c)]
getindex(x::TS, r::Int, c::UTF8String) = x[r, find(x.fields .== c)]
getindex(x::TS, r::AbstractArray{Int,1}, c::UTF8String) = x[r, find(x.fields .== c)]
getindex(x::TS, ::Colon, c::Vector{UTF8String}) = x[:, find(overlaps(x.fields, c))]
getindex(x::TS, r::Int, c::Vector{UTF8String}) = x[r, find(overlaps(x.fields, c))]
getindex(x::TS, r::AbstractArray{Int,1}, c::Vector{UTF8String}) = x[r, find(overlaps(x.fields, c))]
#=
Check if string a valid date format
    Possible syntax:
        yyyy (4)
        yyyy:: (6)
        ::yyyy (6)
        yyyy-mm (7)
        yyyy-mm:: (9)
        ::yyyy-mm (9)
        yyyy::yyyy (10)
        yyyy-mm-dd (10)
        yyyy-mm-dd:: (12)
        yyyy-mm::yyyy-mm (16)
        yyyy-mm-dd::yyyy (16)
        yyyy-mm-dd::yyyy-mm (19)
        yyyy-mm-ddTHH:MM:SS (19)
        yyyy-mm-dd::yyyy-mm-dd (22)
        yyyy-mm-ddTHH:MM:SS::yyyy (25)
        yyyy::yyyy-mm-ddTHH:MM:SS (25)
        yyyy-mm::yyyy-mm-ddTHH:MM:SS (28)
        yyyy-mm-ddTHH:MM:SS::yyyy-mm (28)
        yyyy-mm-dd::yyyy-mm-ddTHH:MM:SS (31)
        yyyy-mm-ddTHH:MM:SS::yyyy-mm-dd (31)
        yyyy-mm-ddTHH:MM:SS::yyyy-mm-ddTHH (34)
        yyyy-mm-ddTHH:MM:SS::yyyy-mm-ddTHH:MM (37)
        yyyy-mm-ddTHH:MM:SS::yyyy-mm-ddTHH:MM:SS (40)
=#
function parsedate(s::AbstractString, t::Vector{Date})
    @assert !in('T', s) "Cannot index Date type with sub-daily frequency."
    bds = split(s, "::")
    if length(bds) == 1  # single time step
        n = length(bds[1])
        if n == 4
            return find(year(t) .== parse(Int, bds[1]))
        elseif n == 7
            y, m = split(bds[1], '-')
            return (find((year(t).==parse(Int,y)) .* (month(t).==parse(Int,m))))
        elseif n == 10
            y, m, d = split(bds[1], '-')
            return (find((year(t).==parse(Int,y)) .* (month(t).==parse(Int,m)) .* (day(t).==parse(Int,d))))
        else
            error("Invalid indexing string: Unable to parse $s")
        end
    elseif length(bds) == 2  # temporal range
        if bds[1] == "" && bds[2] != ""
        elseif bds[2] == "" && bds[1] != ""
        else
            error("Invalid indexing string: Unable to parse $s")
        end
    else
        error("Invalid indexing string: Unable to parse $s")
    end
end
