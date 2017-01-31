# const SHOWROWS = 5  # number of rows to print at beginning and end
const DECIMALS = 4  # the maximum number of decimals to show
const PADDING = 2  # number of spaces minimum between fields
const SHOWINT = false  # whether to format integer columns without decimals

import Base: isinteger, strwidth, rpad, summary
rpad(s::Symbol, n::Int)::String = rpad(string(s), n)
isinteger(::String)::Bool = false
isinteger(::Symbol)::Bool = false
isinteger(::Char)::Bool = false
isinteger(::Date)::Bool = false
isinteger(::DateTime)::Bool = false
isinteger(::Function)::Bool = false
strwidth(s::Symbol)::Int = strwidth(string(s))
strwidth(n::Number)::Int = strwidth(string(n))
strwidth(f::Function)::Int = strwidth(string(f))
strwidth(b::Bool)::Int = b ? 4 : 5
strwidth(c::Char)::Int = 1

function summary{V,T}(x::TS{V,T})::String
    if isempty(x)
        return @sprintf("Empty %s", typeof(x))
    else
        return @sprintf("%ix%i %s: %s to %s", size(x,1), size(x,2), typeof(x), x.index[1], x.index[end])
    end
end

function getidxwidth{V,T}(x::TS{V,T})::Int
    (T == Date ? 10 : 19)
end

function getshowrows{V,T}(io::IO, x::TS{V,T})::Tuple{Vector{Int},Vector{Int}}
    nrow = size(x,1)
    dims = displaysize(io)
    row_chunk_size = fld(dims[1]-5, 2) - 1
    return (collect(1:row_chunk_size), collect(nrow-row_chunk_size:nrow))
end

function getcolwidths{V,T}(x::TS{V,T})::Vector{Int}
    widths = strwidth.(x.fields)
    vals = x.values
    ncol = size(x,2)
    if V <: Number
        @inbounds for j in 1:ncol
            widths[j] = max(widths[j], strwidth(@sprintf("%.4f", maximum(vals[:,j]))))
        end
    else
        @inbounds for j in 1:ncol
            widths[j] = max(widths[j], maximum(strwidth.(vals[:,j])))
        end
    end
    return widths
end

function getwidths(x::TS)::Vector{Int}
    return [getidxwidth(x); getcolwidths(x)] .+ PADDING
end

function printheader(io::IO, x::TS)::Void
    widths = getwidths(x)
    println(io, rpad("Index", widths[1]-2) * prod(lpad.(string.(x.fields), widths[2:end])))
    nothing
end

function printrows(io::IO, x::TS)::Void
    nrow = size(x,1)
    dims = displaysize(io)
    widths = getwidths(x)
    if dims[1] <= nrow
        toprows, botrows = getshowrows(io,x)
        vals = x.values[[toprows;botrows], :]
        @inbounds for row in toprows
            println(io, prod(lpad.([string(x.index[row]);string.(x.values[row,:])], widths))[PADDING+1:end])
        end
        println(io, "...")
        @inbounds for row in botrows
            println(io, prod(lpad.([string(x.index[row]);string.(x.values[row,:])], widths))[PADDING+1:end])
        end
    else
        @inbounds for row in 1:nrow
            println(io, prod(lpad.([string(x.index[row]);string.(x.values[row,:])], widths))[PADDING+1:end])
        end
    end
    nothing
end

function show{V,T}(io::IO, x::TS{V,T})::Void
    println(io, summary(x))
    printheader(io, x)
    printrows(io, x)
    nothing
end

