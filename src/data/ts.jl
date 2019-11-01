import Base: size, length, show, iterate, lastindex, isempty, convert, ndims, float, eltype, copy, ==

const SANITIZE_NAMES = false

################################################################################
# TYPE DEFINITION ##############################################################
################################################################################

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
end

function rename!(f::Base.Callable, ts::TS, colnametyp::Type{Symbol} = Symbol)
    for (i, field) in enumerate(ts.fields)
        ts.fields[i] = f(field)
    end
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
