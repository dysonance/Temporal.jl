import Base: size, length, show, getindex, start, next, done, endof, isempty
using Base.Dates

################################################################################
# TYPE DEFINITION ##############################################################
################################################################################
Str = Union{AbstractString, ASCIIString, ByteString, DirectIndexString,
            UTF8String, UTF16String, UTF32String, RepString, RopeString}
abstract ATS
@doc """
Time series type aimed at efficiency and simplicity.
Motivated by the `xts` package in R and the `pandas` package in Python.
""" ->
type TS{V<:Number, T<:TimeType, F<:Str} <: ATS
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
# ITERATOR PROTOCOL ############################################################
################################################################################
size(x::ATS) = size(x.values)
size(x::ATS, dim::Int) = size(x.values, dim)
start(x::TS) = 1
next(x::TS, i::Int) = ((x.index[i], x.values[i,:]), i+1)
done(x::TS, i::Int) = (i > size(x,1))
isempty(x::TS) = (isempty(x.index) && isempty(x.values))
endof(x::TS) = size(x,1)
length(x::TS) = prod(size(x))::Int
first(x::TS) = x[1]
last(x::TS) = x[end]

################################################################################
# INDEXING #####################################################################
################################################################################
# NUMERICAL INDEXING -----------------------------------------------------------
getindex(x::TS) = x
getindex(x::TS, r::Int) = size(x,2) > 1 ? TS(x.values[r,:], x.index[[r]], x.fields) : TS(x.values[[r]], x.index[[r]], x.fields)
getindex(x::TS, r::Int, c::Int) = TS([x.values[r,c]], [x.index[r]], [x.fields[c]])
getindex(x::TS, r::Int, c::Vector{Int}) = TS(x.values[r,c], [x.index[r]], x.fields[c])
getindex(x::TS, r::Int, c::UnitRange{Int}) = TS(x.values[r,c], [x.index[r]], x.fields[c])
getindex(x::TS, r::Int, c::Colon) = TS(x.values[r,:], [x.index[r]], x.fields)
getindex(x::TS, r::Vector{Int}) = TS(x.values[r,:], x.index[r], x.fields)
getindex(x::TS, r::Vector{Int}, c::Int) = TS(x.values[r,c], x.index[r], [x.fields[c]])
getindex(x::TS, r::Vector{Int}, c::Vector{Int}) = TS(x.values[r, c], x.index[r], x.fields[c])
getindex(x::TS, r::Vector{Int}, c::UnitRange{Int}) = TS(x.values[r, c], x.index[r], x.fields[c])
getindex(x::TS, r::Vector{Int}, c::Colon) = TS(x.values[r,:], x.index[r], x.fields)
getindex(x::TS, r::UnitRange{Int}) = TS(x.values[r,:], x.index[r], x.fields)
getindex(x::TS, r::UnitRange{Int}, c::Int) = TS(x.values[r,c], x.index[r], [x.fields[c]])
getindex(x::TS, r::UnitRange{Int}, c::Vector{Int}) = TS(x.values[r, c], x.index[r], x.fields[c])
getindex(x::TS, r::UnitRange{Int}, c::UnitRange{Int}) = TS(x.values[r, c], x.index[r], x.fields[c])
getindex(x::TS, r::UnitRange{Int}, c::Colon) = TS(x.values[r,:], x.index[r], x.fields)
getindex(x::TS, r::Colon) = x
getindex(x::TS, r::Colon, c::Int) = TS(x.values[:,c], x.index, [x.fields[c]])
getindex(x::TS, r::Colon, c::Vector{Int}) = TS(x.values[:,c], x.index, x.fields[c])
getindex(x::TS, r::Colon, c::UnitRange{Int}) = TS(x.values[:,c], x.index, x.fields[c])
getindex(x::TS, r::Colon, c::Colon) = x

# DATE INDEXING ----------------------------------------------------------------
whichdate(t::TimeType, idx::Vector{Date}) = find(map(r -> r == t, idx))[1]
whichdate(t::TimeType, idx::Vector{DateTime}) = find(map(r -> r == t, idx))[1]
function whichdate(t::Vector{Date}, idx::Vector{Date})
    r = Int[]
    for i in 1:size(t,1)
        append!(r, find(map((r) -> r == t[i], idx)))
    end
    return r
end
function whichdate(t::Vector{DateTime}, idx::Vector{DateTime})
    r = Int[]
    for i in 1:size(t,1)
        append!(r, find(map((r) -> r == t[i], idx)))
    end
    return r
end
getindex(x::TS, t::TimeType) = x[whichdate(t, x.index)]
getindex(x::TS, t::TimeType, c) = x[whichdate(t, x.index), c]
getindex(x::TS, t::Vector{Date}) = x[whichdate(t, x.index)]
getindex(x::TS, t::Vector{Date}, c) = x[whichdate(t, x.index), c]
getindex(x::TS, t::Vector{DateTime}) = x[whichdate(t, x.index)]
getindex(x::TS, t::Vector{DateTime}, c) = x[whichdate(t, x.index), c]

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
# Set up date string parser helper functions
const DTCHARS = Char['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', ':', 'T']
const DTLENGTHS = Int[4, 6, 7, 9, 10, 12, 16, 19, 22, 25, 28, 31, 34, 37, 40]
isdt(c::Char) = in(c, DTCHARS)
isdt(s::Str) = all(map(isdt, collect(s)))
isvalidlength(s::Str) = in(length(s), DTLENGTHS)
isrowidx(s::Str) = isdt(s) && isvalidlength(s)
function whichfield(x::TS, s::Str)
    for j = 1:size(x,2)
        if s == x.fields[j]
            return j
        end
    end
    error("Invalid field name given.")
end
function whichfield(x::TS, s::Vector{Str})
    k = length(s)
    c = Array{Int,1}(zeros(k))
    for j = 1:k
        c[j] = whichfield(x, s)
    end
    c = c[find(c)]
    if isempty(c)
        error("Unable to identify any valid field names.")
    elseif length(c) != k
        warn("Unable to identify $(k-length(c)) field names.")
    end
    return c
end
# TODO: fix string subtype bugs
getindex(x::TS, r::Int, s::Str) = x[r, whichfield(x, s)]
getindex(x::TS, r::Date, s::Str) = x[r, whichfield(x, s)]
getindex(x::TS, r::DateTime, s::Str) = x[r, whichfield(x, s)]
getindex(x::TS, r::Vector{Int}, s::Str) = x[r, whichfield(x, s)]
getindex(x::TS, r::Vector{Date}, s::Str) = x[r, whichfield(x, s)]
getindex(x::TS, r::Vector{DateTime}, s::Str) = x[r, whichfield(x, s)]
getindex(x::TS, r::UnitRange{Int}, s::Str) = x[r, whichfield(x, s)]
getindex(x::TS, r::StepRange{Date}, s::Str) = x[r, whichfield(x, s)]
getindex(x::TS, r::StepRange{DateTime}, s::Str) = x[r, whichfield(x, s)]
getindex(x::TS, r::Colon, s::Str) = x[r, whichfield(x, s)]
getindex(x::TS, r::Int, s::Vector{Str}) = x[r, whichfield(x, s)]
getindex(x::TS, r::Date, s::Vector{Str}) = x[r, whichfield(x, s)]
getindex(x::TS, r::DateTime, s::Vector{Str}) = x[r, whichfield(x, s)]
getindex(x::TS, r::Vector{Int}, s::Vector{Str}) = x[r, whichfield(x, s)]
getindex(x::TS, r::Vector{Date}, s::Vector{Str}) = x[r, whichfield(x, s)]
getindex(x::TS, r::Vector{DateTime}, s::Vector{Str}) = x[r, whichfield(x, s)]
getindex(x::TS, r::UnitRange{Int}, s::Vector{Str}) = x[r, whichfield(x, s)]
getindex(x::TS, r::StepRange{Date}, s::Vector{Str}) = x[r, whichfield(x, s)]
getindex(x::TS, r::StepRange{DateTime}, s::Vector{Str}) = x[r, whichfield(x, s)]
getindex(x::TS, r::Colon, s::Vector{Str}) = x[r, whichfield(x, s)]

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



