import Base: size, length, show, getindex, isempty, convert
import Base: size, length, show, getindex, start, next, done, endof, isempty
using Base.Dates


################################################################################
# TYPE DEFINITION ##############################################################
################################################################################
abstract AbstractTS
@doc doc"""
Time series type aimed at efficiency and simplicity.
Motivated by the `xts` package in R and the `pandas` package in Python.
""" ->
type TS{V<:Number, T<:TimeType} <: AbstractTS
    values::AbstractArray{V}
    index::Vector{T}
    fields::Vector{ByteString}
    function TS(values, index, fields)
		@assert size(values,1) == length(index) "Length of index not equal to number of value rows."
		@assert size(values,2) == length(fields) "Length of fields not equal to number of columns in values."
        if size(values,2) == 1
            values = hcat(values)  # ensure 2-dimensional array
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

TS{V,T}(v::AbstractArray{V}, t::Vector{T}, f::ByteString) = TS{V,T}(v, t, [f])
TS{V,T}(v::AbstractArray{V}, t::Vector{T}, f::ASCIIString) = TS{V,T}(v, t, ByteString[f])
TS{V,T}(v::AbstractArray{V}, t::Vector{T}, f::UTF8String) = TS{V,T}(v, t, ByteString[f])
TS{V,T}(v::AbstractArray{V}, t::Vector{T}, f::Vector{ByteString}) = TS{V,T}(v, t, f)
TS{V,T}(v::AbstractArray{V}, t::Vector{T}, f::Vector{ASCIIString}) = TS{V,T}(v, t, Vector{ByteString}(f))
TS{V,T}(v::AbstractArray{V}, t::Vector{T}, f::Vector{UTF8String}) = TS{V,T}(v, t, Vector{ByteString}(f))
TS{V,T}(v::AbstractArray{V}, t::Vector{T}, f::Char) = TS{V,T}(v, t, ByteString[string(f)])
TS{V,T}(v::AbstractArray{V}, t::Vector{T}, f::Vector{Char}) = TS{V,T}(v, t, ByteString[string(fld) for fld=f])
TS{V,T}(v::AbstractArray{V}, t::T, f::Vector{ByteString}) = TS{V,T}(v, [t], f)
function autocolname(idx::Int)
    if idx < 1
        error("Column index too small.")
    elseif idx <= 26
        return string(Char(64 + idx))
    end
    colname = ""
    modulo = 0
    dividend = idx
    while dividend > 0
        modulo = (dividend - 1) % 26
        colname = string(Char(65 + modulo)) * colname
        dividend = Int(round((dividend - modulo) / 26))
    end
    return colname
end
TS{V,T}(v::Array{V}, t::Vector{T}) = TS{V,T}(v, t, map(autocolname, 1:size(v,2)))

# Conversions ------------------------------------------------------------------
convert(::Type{TS{Float64}}, x::TS{Bool}) = TS{Float64}(map(Float64, x.values), x.index, x.fields)
convert(x::TS{Bool}) = convert(TS{Float64}, x::TS{Bool})
typealias ts TS

################################################################################
# BASIC UTILITIES ##############################################################
################################################################################
size(x::TS) = size(x.values)
size(x::TS, dim::Int) = size(x.values, dim)
start(x::TS) = 1
next(x::TS, i::Int) = ((x.index[i], x.values[i,:]), i+1)
done(x::TS, i::Int) = (i > size(x,1))
isempty(x::TS) = (isempty(x.index) && isempty(x.values))
endof(x::TS) = size(x,1)
length(x::TS) = prod(size(x))::Int
first(x::TS) = x[1]
last(x::TS) = x[end]
endof(x::TS) = endof(x.values)

################################################################################
# SHOW / PRINT METHOD ##########################################################
################################################################################
const DECIMALS = 4
const SHOWINT = true
function show{V,T}(io::IO, x::TS{V,T})
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
        print(io, fields[j], ^(" ", colwidth[j] - strwidth(string(fields[j])) + 2))
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
                        print(io, rpad(round(Integer, x.values[i,j]), colwidth[j]+2, " "))
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

