import Base: size, length, show, start, next, done, endof, isempty, convert, ndims, float, eltype, copy
using Base.Dates

################################################################################
# TYPE DEFINITION ##############################################################
################################################################################
findalphanum(s::AbstractString)::Vector{Int} = union(find(isalpha,s), find(isnumber,s))
# findalphanum(s::String)::Vector{Int} = find(isalpha.(split(s,"")).+isnumber.(split(s,"")))
namefix(s::AbstractString)::AbstractString = s[findalphanum(s)]
namefix(s::Symbol)::Symbol = Symbol(namefix(string(s)))

# abstract AbstractTS
# 
# @doc doc"""
# Time series type aimed at efficiency and simplicity.
# 
# Motivated by the `xts` package in R and the `pandas` package in Python.
# """ ->
# type TS{V<:Any, T<:TimeType} <: AbstractTS
#     values::AbstractArray{V}
#     index::Vector{T}
#     fields::Vector{Symbol}
#     function TS(values, index, fields)
#         @assert size(values,1) == length(index) "Length of index not equal to number of value rows."
#         @assert (isempty(values) && isempty(fields)) || (size(values,2) == length(fields)) "Length of fields not equal to number of columns in values."
#         order = sortperm(index)
#         if size(values,2) == 1
#             return new(values[order], index[order], namefix.(fields))
#         else
#             return new(values[order,:], index[order], namefix.(fields))
#         end
#     end
# end

abstract type AbstractTS end

@doc doc"""
Time series type aimed at efficiency and simplicity.

Motivated by the `xts` package in R and the `pandas` package in Python.
""" ->
mutable struct TS{V<:Real,T<:TimeType}
    values::Matrix{V}
    index::Vector{T}
    fields::Vector{Symbol}
    function TS{V,T}(values, index, fields) where {V<:Real,T<:TimeType}
        @assert size(values,1)==length(index) "Length of index not equal to number of value rows."
        @assert size(values,2)==length(fields) || (isempty(fields) && isempty(values)) "Length of fields not equal to number of columns in values."
        order = sortperm(index)
        return new(values[order,:], index[order], namefix.(fields))
    end
end

function autocol(col::Int)
    @assert col >= 1 "Invalid column number $col - cannot generate column name"
    if col <= 26
        return Symbol(Char(64 + col))
    end
    colname = ""
    modulo = 0
    dividend = col
    while dividend > 0
        modulo = (dividend - 1) % 26
        colname = string(Char(65 + modulo)) * colname
        dividend = Int(round((dividend - modulo) / 26))
    end
    return Symbol(colname)
end
autocol(cols::AbstractArray{Int,1}) = map(autocol, cols)
autoidx(n::Int; dt::Period=Day(1), from::Date=today()-(n-1)*dt, thru::Date=from+(n-1)*dt) = collect(from:dt:thru)

TS{V,T}(v::AbstractArray{V}, t::Vector{T}, f::Symbol) = TS{V,T}(v, t, [f])
TS{V,T}(v::AbstractArray{V}, t::Vector{T}, f::Vector{Symbol}) = TS{V,T}(v, t, f)
TS{V,T}(v::AbstractArray{V}, t::Vector{T}, f::Char) = TS{V,T}(v, t, Symbol[f])
TS{V,T}(v::AbstractArray{V}, t::Vector{T}, f::String) = TS{V,T}(v, t, Symbol[f])
TS{V,T}(v::AbstractArray{V}, t::Vector{T}, f::Vector{Char}) = TS{V,T}(v, t, Symbol.(f))
TS{V,T}(v::AbstractArray{V}, t::Vector{T}, f::Vector{String}) = TS{V,T}(v, t, Symbol.(f))
TS{V,T}(v::AbstractArray{V}, t::Vector{T}) = TS{V,T}(v, t, autocol(1:size(v,2)))
TS{V,T}(v::V, t::T, f::Symbol) = TS{V,T}([v], [t], f)
TS{V,T}(v::AbstractArray{V}, t::T, f::Vector{Symbol}) = TS{V,T}(v, [t], f)
TS{V,T}(v::V, t::T, f::Vector{Symbol}) = TS{V,T}([v], [t], f)
TS{V,T}(v::V, t::T) = TS{V,T}([v], [t], :A)
TS() = TS([], Date[], Symbol[])
TS(v::AbstractArray, t::StepRange) = TS(v, collect(t))
TS(v::AbstractArray) = TS(v, today()-Day(size(v,1)-1):Day(1):today())

# Conversions ------------------------------------------------------------------
convert(::Type{TS{Float64}}, x::TS{Bool}) = TS{Float64}(map(Float64, x.values), x.index, x.fields)
convert(::Type{TS{Int}}, x::TS{Bool}) = TS{Int}(map(Int, x.values), x.index, x.fields)
convert(x::TS{Bool}) = convert(TS{Int}, x::TS{Bool})
# convert{V}(::Type{TS}, x::Array{V}) = TS{V,Date}(x, [Dates.Date() for i in 1:size(x,1)])
# convert(x::TS{Bool}) = convert(TS{Float64}, x::TS{Bool})
const ts = TS

################################################################################
# BASIC UTILITIES ##############################################################
################################################################################
size(x::TS) = size(x.values)
size(x::TS, dim::Int) = size(x.values, dim)
length(x::TS) = prod(size(x))::Int
start(x::TS) = 1
next(x::TS, i::Int) = ((x.index[i], x.values[i,:]), i+1)
done(x::TS, i::Int) = (i > size(x,1))
isempty(x::TS) = (isempty(x.index) && isempty(x.values))
first(x::TS) = x[1]
last(x::TS) = x[end]
endof(x::TS) = endof(x.values)
ndims(::TS) = 2
float(x::TS) = ts(float(x.values), x.index, x.fields)
eltype(x::TS) = eltype(x.values)
copy(x::TS) = TS(x.values, x.index, x.fields)
# round(V::Type, x::TS) = TS(round(V, x.values), x.index, x.fields)

