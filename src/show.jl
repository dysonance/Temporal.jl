# const SHOWROWS = 5  # number of rows to print at beginning and end
const DECIMALS = 4  # the maximum number of decimals to show
const PADDING = 2  # number of spaces minimum between fields
const SHOWINT = false  # whether to format integer columns without decimals

# rpad(s::Symbol, n::Int)::String = rpad(string(s), n)
# isinteger(::String)::Bool = false
# isinteger(::Symbol)::Bool = false
# isinteger(::Char)::Bool = false
# isinteger(::Date)::Bool = false
# isinteger(::DateTime)::Bool = false
# isinteger(::Function)::Bool = false
# strwidth(s::Symbol)::Int = strwidth(string(s))
# strwidth(n::Number)::Int = strwidth(string(n))
# strwidth(f::Function)::Int = strwidth(string(f))
# strwidth(b::Bool)::Int = b ? 4 : 5
# strwidth(c::Char)::Int = 1

str_width(s::AbstractString)::Int = strwidth(s)
str_width(s::Symbol)::Int = strwidth(string(s))
str_width(n::Number)::Int = strwidth(string(n))
str_width(f::Function)::Int = strwidth(string(f))
str_width(b::Bool)::Int = b ? 4 : 5
str_width(c::Char)::Int = 1

function print_summary{V,T}(io::IO, x::TS{V,T})::Int
    if isempty(x)
        println(@sprintf("Empty %s", typeof(x)))
        return 0
    else
        println(@sprintf("%ix%i %s: %s to %s", size(x,1), size(x,2), typeof(x), x.index[1], x.index[end]))
        return 1
    end
end

function getshowrows{V,T}(io::IO, x::TS{V,T})::Tuple{Vector{Int},Vector{Int}}
    nrow = size(x,1)
    dims = displaysize(io)
    if nrow > dims[1]
        row_chunk_size = fld(dims[1]-4, 2) - 1
        return (collect(1:row_chunk_size), collect(nrow-row_chunk_size:nrow))
    else
        return (collect(1:fld(nrow,2)), collect(fld(nrow,2)+1:nrow))
    end
end

function getwidths{V,T}(io::IO, x::TS{V,T})::Vector{Int}
    widths = [T==Date?10:19; str_width.(x.fields)]
    toprows, botrows = getshowrows(io, x)
    vals = [x.values[toprows,:]; x.values[botrows,:]]
    if V <: Number
        @inbounds for j in 1:size(x,2)
            widths[j+1] = max(widths[j+1], maximum(str_width.(round.(vals[:,j],DECIMALS))))
        end
    else
        @inbounds for j in 1:size(x,2)
            widths[j+1] = max(widths[j+1], maximum(str_width.(vals[:,j])))
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

print_header(x::TS, widths::Vector{Int}, negs::Vector{Bool})::String = prod(rpad.(["Index"; lpad.(string.(x.fields), str_width.(x.fields).+negs)], widths))

function print_row{V,T}(x::TS{V,T}, row::Int, widths::Vector{Int}, negs::Vector{Bool})::String
    if V <: Number
        return prod(rpad.([string(x.index[row]); [" "].^(negs.*(x.values[row,:].>=0.0)) .* string.(round.(x.values[row,:],DECIMALS))], widths))
    else
        return prod(rpad.([string(x.index[row]); string.(x.values[row,:])], widths))
    end
end

function print_rows(io::IO, x::TS, widths::Vector{Int}=getwidths(io,x).+PADDING, negs::Vector{Bool}=getnegs(io,x))::Void
    # negs = getnegs(io,x)
    # widths = getwidths(io,x) .+ PADDING
    nrow = size(x,1)
    ncol = size(x,2)
    toprows, botrows = getshowrows(io,x)
    if nrow > 1
        @inbounds for row in toprows
            println(io, print_row(x, row, widths, negs))
        end
        if toprows[end] < botrows[1] - 1
            println(io, "⋮")
        end
    end
    @inbounds for row in botrows[1:end-1]
        println(io, print_row(x, row, widths, negs))
    end
    print(io, print_row(x, botrows[end], widths, negs))
    nothing
end

function show{V,T}(io::IO, x::TS{V,T})::Void
    if print_summary(io, x) == 0
        return nothing
    end
    # println()  # print whitespace before actualy data starts to improve readability
    widths = getwidths(io, x) .+ PADDING
    negs = getnegs(io, x)
    println(io, print_header(x, widths, negs))
    print_rows(io, x, widths, negs)
    nothing
end
