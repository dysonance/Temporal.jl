# TODO: finish column subsetting
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
    flds::Vector{F}
    function TS(values, index, flds)
        if size(values,1) != length(index)
            error("Length of index not equal to number of value rows.")
        end
        if size(values,2) == 1
            values = hcat(values)  # ensure 2-dimensional array
        end
        if length(flds) != size(values,2)
            error("Length of flds not equal to number of columns in values")
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
        new(values, index, flds)
    end
end
TS{V,T,F}(v::Array{V}, t::Vector{T}, f::Vector{F}) = TS{V,T,F}(v,t,f)
TS{V,T}(v::Array{V}, t::Vector{T}) = TS{V,T,ByteString}(v, t, [string("V",i) for i=1:size(v,2)])
TS{V}(v::Array{V}) = TS{V,Date,ByteString}(v, [today()-Day(i) for i=size(v,1):-1:1], [string("V",i) for i=1:size(v,2)])


# Conversions ------------------------------------------------------------------
convert(::Type{TS{Float64}}, x::TS{Bool}) = TS{Float64}(map(Float64, x.values), x.index, x.flds)
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
#TODO: allow use of `end` keyword
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
        return TS(x.values[i,:], x.index[[i]], x.flds)
    else
        return TS(x.values[[i]], x.index[[i]], x.flds)
    end
end
# Range of rows
function getindex(x::TS, r::AbstractArray)
    return TS(x.values[r,:], x.index[r], x.flds)
end
# Range of rows + range of columns
function getindex(x::TS, r::AbstractArray, c::AbstractArray)
    checksize(x, r, c)
    return TS(x.values[r, c], x.index[r], x.flds[c])
end
# Range of rows + single column
function getindex(x::TS, r::AbstractArray, c::Int)
    checksize(x, r, c)
    return TS(x.values[r,c], x.index[r], [x.flds[c]])
end
# Single row + range of columns
function getindex(x::TS, r::Int, c::AbstractArray)
    checksize(x, r, c)
    return TS(x.values[r,c], [x.index[r]], x.flds[c])
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
    return TS(x.values[r,:], [x.index[r]], x.flds)
end
function getindex(x::TS, r::AbstractArray, ::Colon)
    checksize(x, r)
    return TS(x.values[r,:], x.index[r], x.flds)
end
function getindex(x::TS, ::Colon, c::Int)
    checksize(x, Void, c)
    return TS(x.values[:,c], x.index, [x.flds[c]])
end
function getindex(x::TS, ::Colon, c::AbstractArray)
    checksize(x, Void, c)
    return TS(x.values[:,c], x.index, x.flds[c])
end
# Single element indexing
function getindex(x::TS, r::Int, c::Int)
    checksize(x, r, c)
    return TS([x.values[r,c]], [x.index[r]], [x.flds[c]])
end

#TODO:
# STRING INDEXING --------------------------------------------------------------

#TODO:
# DATE INDEXING ----------------------------------------------------------------


################################################################################
# OPERATIONS ###################################################################
################################################################################



################################################################################
# SHOW / PRINT METHOD ##########################################################
################################################################################
DECIMALS = 4
SHOWINT = true
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
    if eltype(x.flds) <: Number
        flds = [string(x.flds[j]) for j=1:ncol]
    else
        flds = x.flds
    end
    for j = 1:ncol
        rowcheck = trunc(x.values[:,j]) - x.values[:,j] .== 0.0
        if all(rowcheck)
            intcatcher[j] = true
        end
    end
    spacetime = nrow > 0 ? strwidth(string(x.index[1])) + 3 : 3
    firstcolwidth = strwidth(flds[1])
    colwidth = Int[]
    for j = 1:ncol
        if T == Bool || nrow == 0
            push!(colwidth, max(strwidth(flds[j]), 5))
        else
            push!(colwidth, max(strwidth(flds[j]), strwidth(@sprintf("%.2f", maximum(x.values[:,j]))) + DECIMALS - 2))
        end
    end

    # Summary line
    @printf(io, "%dx%d %s", nrow, ncol, typeof(x))
    nrow > 0 && @printf(io, " %s to %s", string(x.index[1]), string(x.index[end]))
    println(io, "")
    println(io, "")

    # Field names line
    print(io, "Index ", ^(" ", spacetime-6), flds[1], ^(" ", colwidth[1] + 2 - firstcolwidth))
    for j = 2:length(colwidth)
        print(io, flds[j], ^(" ", colwidth[j] - strwidth(flds[j]) + 2))
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



