# TODO: figure out end keyword
# TODO: index columns by field name
# TODO: index rows by date (i.e. xts '2010-01::' syntax)
import Base: size, length, show, getindex, isempty, convert
using Base.Dates

################################################################################
# TYPE DEFINITION ##############################################################
################################################################################
abstract ATS
@doc """
Time series type aimed at efficiency and simplicity.
Motivated by the `xts` package in R and the `pandas` package in Python.
""" ->
type TS{V<:Number, T<:TimeType, F<:Any} <: ATS
    values::Array{V}
    index::Vector{T}
    fields::Vector{F}
    function TS(values, index, fields)
        if size(values,1) != length(index)
            error("Length of index not equal to number of value rows.")
        end
        if size(values,2) == 1
            values = hcat(values)  # ensure 2-dimensional array
        end
        if length(fields) != size(values,2)
            error("Length of fields not equal to number of columns in values")
        end
        order = sortperm(index)
        index = index[order]
        if size(values,2) > 1
            for j = 1:size(values,2)
                values[:,j] = values[order,j]
            end
        else
            values = values[order]
        end
        new(values, index, fields)
    end
end
TS{V,T,F}(v::Array{V}, t::Vector{T}, f::Vector{F}) = TS{V,T,F}(v,t,f)
TS{V,T}(v::Array{V}, t::Vector{T}) = TS{V,T,ByteString}(v, t, [string("V",i) for i=1:size(v,2)])
TS{V}(v::Array{V}) = TS{V,Date,ByteString}(v, [today()-Day(i) for i=size(v,1):-1:1], [string("V",i) for i=1:size(v,2)])


# Conversions ------------------------------------------------------------------
convert(::Type{TS{Float64}}, x::TS{Bool}) = TS{Float64}(map(Float64, x.values), x.index, x.fields)
convert{V<:Number, T<:TimeType, F<:Any}(::Type{TS{V,T,F}}, v::Array{V}, t::Vector{T}, f::Vector{F}) = TS(v,t,f)
convert(x::TS{Bool}) = convert(TS{Float64}, x::TS{Bool})

typealias ts TS

################################################################################
# SIZE METHODS #################################################################
################################################################################
function size(x::ATS)
    return size(x.values)
end

function size(x::ATS, dim::Int)
    return size(x.values, dim)
end

function length(x::ATS)
    return size(x,1)
end


################################################################################
# ITERATOR PROTOCOL ############################################################
################################################################################
start(x::TS) = 1
next(x::TS, i::Int) = ((x.index[i], x.values[i,:]), i+1)
done(x::TS, i::Int) = (i > size(x,1))
isempty(x::TS) = (isempty(x.index) && isempty(x.values))

################################################################################
# INDEXING #####################################################################
################################################################################

# NUMERICAL INDEXING -----------------------------------------------------------
function extent(r::AbstractArray)
    return length(r)
end
function extent(r::Int)
    return r
end
function checksize(x::TS, r=Void, c=Void)
    if r != Void && size(x,1) < extent(r)
        error("Dimension mismatch: row index")
    end
    if c != Void && size(x,2) < extent(c)
        error("Dimension mismatch: column index")
    end
    return true
end
# end keyword function
function endof(x::ATS)
    return endof(x.values)
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

#TODO:
# DATE INDEXING ----------------------------------------------------------------
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

#TODO:
# STRING INDEXING --------------------------------------------------------------
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



################################################################################
# OPERATIONS ###################################################################
################################################################################



################################################################################
# SHOW / PRINT METHOD ##########################################################
################################################################################
const DECIMALS = 4
const SHOWINT = true
function show{V,T,F}(io::IO, x::TS{V,T,F})
    nrow = size(x,1)
    ncol = size(x,2)
    intcatcher = falses(ncol)
    if isempty(x.values)
        @printf(io, "%dx%d %s", nrow, ncol, typeof(x))
        if !isempty(x.index)
            @printf(io, " %s to %s", string(x.index[1]), string(x.index[end]))
        end
        return
    end
    if isempty(x.index)
        x.index = [Date(0) for i=1:nrow]
    end
    if eltype(x.fields) <: Number
        fields = [string(x.fields[j]) for j=1:ncol]
    else
        fields = x.fields
    end
    for j = 1:ncol
        rowcheck = trunc(x.values[:,j]) - x.values[:,j] .== 0.0
        if all(rowcheck)
            intcatcher[j] = true
        end
    end
    spacetime = nrow > 0 ? strwidth(string(x.index[1])) + 3 : 3
    firstcolwidth = strwidth(fields[1])
    colwidth = Int[]
    for j = 1:ncol
        if T == Bool || nrow == 0
            push!(colwidth, max(strwidth(fields[j]), 5))
        else
            push!(colwidth, max(strwidth(fields[j]), strwidth(@sprintf("%.2f", maximum(x.values[:,j]))) + DECIMALS - 2))
        end
    end

    # Summary line
    @printf(io, "%dx%d %s", nrow, ncol, typeof(x))
    nrow > 0 && @printf(io, " %s to %s", string(x.index[1]), string(x.index[end]))
    println(io, "")
    println(io, "")

    # Field names line
    print(io, "Index ", ^(" ", spacetime-6), fields[1], ^(" ", colwidth[1] + 2 - firstcolwidth))
    for j = 2:length(colwidth)
        print(io, fields[j], ^(" ", colwidth[j] - strwidth(fields[j]) + 2))
    end
    println(io, "")

    # Time index & values line
    if nrow > 7
        for i = 1:4
            print(io, x.index[i], " | ")
            for j = 1:ncol
                if T == Bool
                    print(io, rpad(x.values[i,j], colwidth[j]+2, " "))
                else
                    if intcatcher[j] & SHOWINT
                        print(io, rpad(round(Integer, x.values[i,j]), colwdith[j]+2, " "))
                    else
                        print(io, rpad(round(x.values[i,j], DECIMALS), colwidth[j]+2, " "))
                    end
                end
            end
            println(io, "")
        end
        println(io, "...")
        for i = nrow-3:nrow
            print(io, x.index[i], " | ")
            for j = 1:ncol
                if T == Bool
                    print(io, rpad(x.values[i,j], colwidth[j]+2, " "))
                else
                    if intcatcher[j] & SHOWINT
                        print(io, rpad(round(Integer, x.values[i,j]), colwidth[j]+2, " "))
                    else
                        print(io, rpad(round(x.values[i,j], DECIMALS), colwidth[j]+2, " "))
                    end
                end
            end
            println(io, "")
        end
    elseif nrow > 0
        for i = 1:nrow
            print(io, x.index[i], " | ")
            for j = 1:ncol
                if T == Bool
                    print(io, x.index[i], " | ")
                else
                    if intcatcher[j] & SHOWINT
                        print(io, rpad(round(Integer, x.values[i,j]), colwidth[j]+2, " "))
                    else
                        print(io, rpad(round(x.values[i,j], DECIMALS), colwidth[j]+2, " "))
                    end
                end
            end
            println(io, "")
        end
    end
end



