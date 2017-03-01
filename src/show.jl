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

function getshowrows{V,T}(io::IO, x::TS{V,T})::Tuple{Vector{Int},Vector{Int}}
    nrow = size(x,1)
    dims = displaysize(io)
    if nrow > dims[1]
        row_chunk_size = fld(dims[1]-5, 2) - 1
        return (collect(1:row_chunk_size), collect(nrow-row_chunk_size:nrow))
    else
        return (collect(1:fld(nrow,2)), collect(fld(nrow,2)+1:nrow))
    end
end

function getwidths{V,T}(io::IO, x::TS{V,T})::Vector{Int}
    widths = [T==Date?10:19; strwidth.(x.fields)]
    toprows, botrows = getshowrows(io, x)
    vals = [x.values[toprows,:]; x.values[botrows,:]]
    if V <: Number
        @inbounds for j in 1:size(x,2)
            widths[j+1] = max(widths[j+1], maximum(strwidth.(round.(vals[:,j],DECIMALS))))
        end
    else
        @inbounds for j in 1:size(x,2)
            widths[j+1] = max(widths[j+1], maximum(strwidth.(vals[:,j])))
        end
    end
    return widths
end

function printheader(io::IO, x::TS, widths::Vector{Int}=getwidths(io,x).+PADDING)::Void
    println(io, prod(rpad.(["Index"; string.(x.fields)], widths)))
    nothing
end

function printrow{V,T}(io::IO, x::TS{V,T}, row::Int, widths::Vector{Int}=getwidths(io,x).+PADDING)::Void
    if V <: Number
        println(io, prod(rpad.([string(x.index[row]); string.(round.(x.values[row,:],DECIMALS))], widths)))
    else
        println(io, prod(rpad.([string(x.index[row]); string.(x.values[row,:])], widths)))
    end
    nothing
end

function printrows(io::IO, x::TS)::Void
    nrow = size(x,1)
    widths = getwidths(io,x) .+ PADDING
    toprows, botrows = getshowrows(io,x)
    if nrow > 1
        @inbounds for row in toprows
            printrow(io, x, row, widths)
        end
        toprows[end] < botrows[1]-1 ? println(io, "...") : nothing
    end
    @inbounds for row in botrows
        printrow(io, x, row, widths)
    end
    nothing
end

function show{V,T}(io::IO, x::TS{V,T})::Void
    println(io, summary(x))
    printheader(io, x)
    printrows(io, x)
    nothing
end
