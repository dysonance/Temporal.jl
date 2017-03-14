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

function print_summary{V,T}(io::IO, x::TS{V,T})::Void
    if isempty(x)
        println(@sprintf("Empty %s", typeof(x)))
    else
        println(@sprintf("%ix%i %s: %s to %s", size(x,1), size(x,2), typeof(x), x.index[1], x.index[end]))
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

hasnegs{T}(v::Vector{T})::Bool = T<:Number ? any(v.<zero(T)) : false

function getnegs(io::IO, x::TS)::Vector{Bool}
    toprows, botrows = getshowrows(io, x)
    idx = [toprows; botrows]
    return [hasnegs(x.values[:,j]) for j in 1:size(x,2)]
end

function print_header(io::IO, x::TS, widths::Vector{Int}=getwidths(io,x).+PADDING, negs::Vector{Bool}=getnegs(io,x))::Void
    println(io, prod(rpad.(["Index"; string.(x.fields)], widths)))
    nothing
end

function print_row{V,T}(io::IO, x::TS{V,T}, row::Int,
                        widths::Vector{Int}=getwidths(io,x).+PADDING, negs::Vector{Bool}=getnegs(io,x))::Void
    if V <: Number
        println(io, prod(rpad.([string(x.index[row]); [" "].^(negs.*x.values[row,:].>=0.0) .* string.(round.(x.values[row,:],DECIMALS))], widths)))
    else
        println(io, prod(rpad.([string(x.index[row]); string.(x.values[row,:])], widths)))
    end
    nothing
end

# function print_dots(io::IO, x::TS, widths::Vector{Int}=getwidths(io,x))::Void
#     padfix = Int.(iseven.(widths))
#     @inbounds for j in 1:length(widths)
#         print(io, lpad(rpad("⋮", fld(widths[j],2)+padfix[j]), widths[j]))
#     end
#     println(io)
#     nothing
# end

function print_rows(io::IO, x::TS)::Void
    nrow = size(x,1)
    ncol = size(x,2)
    negs = getnegs(io,x)
    widths = getwidths(io,x) .+ PADDING
    toprows, botrows = getshowrows(io,x)
    if nrow > 1
        @inbounds for row in toprows
            print_row(io, x, row, widths, negs)
        end
        if toprows[end] < botrows[1] - 1
            # print__dots(io, x, widths.-[zeros(Int,size(x,2));2])
            println(io, "⋮")
        end
    end
    @inbounds for row in botrows
        print_row(io, x, row, widths, negs)
    end
    nothing
end

function show{V,T}(io::IO, x::TS{V,T})::Void
    # println(io, summary(x))
    print_summary(io, x)
    println()  # print whitespace before actualy data starts to improve readability
    print_header(io, x)
    print_rows(io, x)
    nothing
end
