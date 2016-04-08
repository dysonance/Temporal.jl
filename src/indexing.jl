# end keyword function
function endof(x::ATS)
    return endof(x.values)
end
#===============================================================================
							NUMERICAL INDEXING
===============================================================================#
function extent(r::AbstractArray)
    return length(r)
end
function extent(r::Int)
    return r
end
function extent(r::Void)
	return 0
end
function checksize(x::TS, r=Void, c=Void)
	@assert extent(r) < size(x,1) "Dimension mismatch: row index"
	@assert extent(c) < size(x,2) "Dimension mismatch: column index"
    return true
end
# Single row
function getindex(x::TS, i::Int)
    if size(x,2) > 1
        return TS(x.values[i,:], x.index[[i]], x.fields)
    else
        return TS(x.values[[i]], x.index[[i]], x.fields)
    end
end
# Range of rows
function getindex(x::TS, r::AbstractArray{Int,1})
    return TS(x.values[r,:], x.index[r], x.fields)
end
# Range of rows + range of columns
function getindex(x::TS, r::AbstractArray{Int,1}, c::AbstractArray{Int,1})
    checksize(x, r, c)
    return TS(x.values[r, c], x.index[r], x.fields[c])
end
# Range of rows + single column
function getindex(x::TS, r::AbstractArray{Int,1}, c::Int)
    checksize(x, r, c)
    return TS(x.values[r,c], x.index[r], [x.fields[c]])
end
# Single row + range of columns
function getindex(x::TS, r::Int, c::AbstractArray{Int,1})
    checksize(x, r, c)
    return TS(x.values[r,c], [x.index[r]], x.fields[c])
end
# Empty vector indexing
function getindex(x::TS)
    return x
end
function getindex(x::TS, ::Colon)
    return x
end
# Colon indexing
function getindex(x::TS, r::Int, ::Colon)
    checksize(x, r)
    return TS(x.values[r,:], [x.index[r]], x.fields)
end
function getindex(x::TS, r::AbstractArray{Int,1}, ::Colon)
    checksize(x, r)
    return TS(x.values[r,:], x.index[r], x.fields)
end
function getindex(x::TS, ::Colon, c::Int)
    checksize(x, Void, c)
    return TS(x.values[:,c], x.index, [x.fields[c]])
end
function getindex(x::TS, ::Colon, c::AbstractArray{Int,1})
    checksize(x, Void, c)
    return TS(x.values[:,c], x.index, x.fields[c])
end
# Single element indexing
function getindex(x::TS, r::Int, c::Int)
    checksize(x, r, c)
    return TS([x.values[r,c]], [x.index[r]], [x.fields[c]])
end

#===============================================================================
								DATE INDEXING
===============================================================================#
# One date
function getindex(x::TS, t::TimeType)
    r = find(map((r) -> r == t, x.index))
    return x[r]
end
# One date + columns
function getindex(x::TS, t::TimeType, c)
    r = find(map((r) -> r == t, x.index))
    return x[r, c]
end
# Range of dates
function getindex(x::TS, t::AbstractArray{Date,1})
    r = Int[]
    for i in 1:size(t,1)
        append!(r, find(map((r) -> r == t[i], x.index)))
    end
    return x[r]
end
function getindex(x::TS, t::AbstractArray{DateTime,1})
    r = Int[]
    for i in 1:size(t,1)
        append!(r, find(map((r) -> r == t[i], x.index)))
    end
    return x[r]
end
# Range of dates + columns
function getindex(x::TS, t::AbstractArray{Date,1}, c)
    r = Int[]
    for i in 1:size(t,1)
        append!(r, find(map((r) -> r == t[i], x.index)))
    end
    return x[r, c]
end
function getindex(x::TS, t::AbstractArray{DateTime,1}, c)
    r = Int[]
    for i in 1:size(t,1)
        append!(r, find(map((r) -> r == t[i], x.index)))
    end
    return x[r, c]
end

#===============================================================================
							NUMERICAL INDEXING
===============================================================================#
#=
Check if string a valid date format
    Possible syntax:
        YYYY (4)
        YYYY:: (6)
        YYYY-mm (7)
        YYYY-mm:: (9)
        YYYY::YYYY (10)
        YYYY-mm-dd (10)
        YYYY-mm-dd:: (12)
        YYYY-mm-dd::YYYY (16)
        YYYY-mm-dd::YYYY-mm (19)
        YYYY-mm-ddTHH:MM:SS (19)
        YYYY-mm-dd::YYYY-mm-dd (22)
        YYYY-mm-ddTHH:MM:SS::YYYY (25)
        YYYY-mm-ddTHH:MM:SS::YYYY-mm (28)
        YYYY-mm-ddTHH:MM:SS::YYYY-mm-dd (31)
        YYYY-mm-ddTHH:MM:SS::YYYY-mm-ddTHH (34)
        YYYY-mm-ddTHH:MM:SS::YYYY-mm-ddTHH:MM (37)
        YYYY-mm-ddTHH:MM:SS::YYYY-mm-ddTHH:MM:SS (40)
=#
const DTCHARS = Char['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', ':', 'T']
const NUMCHARS = Char['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']
const DTLENGTHS = Int[4, 6, 7, 9, 10, 12, 16, 19, 22, 25, 28, 31, 34, 37, 40]
function isnum(c::Char)
    return in(c, NUMCHARS)
end
function isnum(s::AbstractString)
    return all(map(isnum, collect(s)))
end
function isdt(c::Char)
    return in(c, DTCHARS)
end
function isdt(s::AbstractString)
    return all(map(isdt, collect(s)))
end
function isvalidlength(s::AbstractString)
    return in(length(s), DTLENGTHS)
end
function isrowidx(s::AbstractString)
    return isdt(s) && isvalidlength(s)
end


