import Base: size, length, show, iterate, lastindex, isempty, convert, ndims, float, eltype, copy, ==
if VERSION >= v"0.7-"
    using Dates
else
    using Base.Dates
end

################################################################################
# TYPE DEFINITION ##############################################################
################################################################################

abstract type AbstractTS end

"""
Time series type aimed at efficiency and simplicity.

Motivated by the `xts` package in R and the `pandas` package in Python.
"""
mutable struct TS{V<:Real,T<:TimeType}
    values::Matrix{V}
    index::Vector{T}
    fields::Vector{Symbol}
    function TS{V,T}(values::AbstractArray{V}, index::AbstractVector{T}, fields::Vector{Symbol}) where {V<:Real,T<:TimeType}
        @assert size(values,1)==length(index) "Length of index not equal to number of value rows."
        @assert size(values,2)==length(fields) "Length of fields not equal to number of columns in values."
        order = sortperm(index)
        return new(values[order,:], index[order], SANITIZE_NAMES ? namefix.(fields) : fields)
    end
end

TS(v::AbstractArray{V}, t::AbstractVector{T}, f::Union{Symbol,String,Char}) where {V,T} = TS{V,T}(v, t, [Symbol(f)])
TS(v::AbstractArray{V}, t::AbstractVector{T}, f::Union{AbstractVector{Symbol},AbstractVector{String},AbstractVector{Char}}) where {V,T} = TS{V,T}(v, t, Symbol.(f))
TS(v::AbstractArray{V}, t::AbstractVector{T}) where {V,T} = TS{V,T}(v, t, autocol(1:size(v,2)))
TS(v::AbstractArray{V}, t::T, f) where {V,T} = TS{V,T}(v, [t], f)
TS(v::V, t::AbstractVector{T}, f) where {V,T} = TS{V,T}([v], t, f)
TS(v::V, t::T, f) where {V,T} = TS{V,T}([v][:,:], [t], f)
TS(v::V, t::T) where {V,T} = TS{V,T}([v], [t], [:A])
TS(v::AbstractArray{V}) where {V} = TS{V,Date}(v, autoidx(size(v,1)), autocol(1:size(v,2)))
TS() = TS{Float64,Date}(Matrix{Float64}(UndefInitializer(),0,0), Date[], Symbol[])
TS(X::TS) = TS(X.values, X.index, X.fields)

# Conversions ------------------------------------------------------------------
convert(::Type{TS{Float64}}, x::TS{Bool}) = TS{Float64}(map(Float64, x.values), x.index, x.fields)
convert(::Type{TS{Int}}, x::TS{Bool}) = TS{Int}(map(Int, x.values), x.index, x.fields)
convert(::Type{TS{Bool}}, x::TS{V}) where {V<:Real} = TS{Bool}(map(V, x.values), x.index, x.fields)
convert(x::TS{Bool}) = convert(TS{Int}, x::TS{Bool})
const ts = TS

################################################################################
# BASIC UTILITIES ##############################################################
################################################################################
size(x::TS) = size(x.values)
size(x::TS, dim::Int) = size(x.values, dim)
ndims(::Type{TS{V,T}}) where {V,T} = 2
length(x::TS) = prod(size(x))::Int
lastindex(x::TS) = lastindex(x.values)
lastindex(x::TS, d) = lastindex(x.values, d)
iterate(x::TS) = size(x,1) == 0 ? nothing : (x.index[1], x.values[1,:]), 2
iterate(x::TS, i::Int) = i == lastindex(x, 1) + 1 ? nothing : ((x.index[i], x.values[i,:]), i+1)
isempty(x::TS) = (isempty(x.index) && isempty(x.values))
first(x::TS) = x[1]
last(x::TS) = x[end]
ndims(::TS) = 2
float(x::TS) = ts(float(x.values), x.index, x.fields)
eltype(x::TS) = eltype(x.values)
copy(x::TS) = TS(x.values, x.index, x.fields)

################################################################################
# RENAME #######################################################################
################################################################################
# in place
function rename!(ts::TS, args::Pair{Symbol, Symbol}...)
    d = Dict{Symbol, Symbol}(args...)
    flag = false
    for (i, field) in enumerate(ts.fields)
        if field in keys(d)
            ts.fields[i] = d[field]
            flag = true
        end
    end
    flag
end

function rename!(f::Base.Callable, ts::TS, colnametyp::Type{Symbol} = Symbol)
    for (i, field) in enumerate(ts.fields)
        ts.fields[i] = f(field)
    end
    true
end

function rename!(f::Base.Callable, ts::TS, colnametyp::Type{String})
    f = Symbol ∘ f ∘ string
    rename!(f, ts)
end

# not in place
function rename(ts::TS, args::Pair{Symbol, Symbol}...)
    ts2 = copy(ts)
    rename!(ts2, args...)
    ts2
end

function rename(f::Base.Callable, ts::TS, colnametyp::Type{Symbol} = Symbol)
    ts2 = copy(ts)
    rename!(f, ts2, colnametyp)
    ts2
end

function rename(f::Base.Callable, ts::TS, colnametyp::Type{String})
    ts2 = copy(ts)
    rename!(f, ts2, colnametyp)
    ts2
end
