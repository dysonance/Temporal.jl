const DECIMALS = 4 # the maximum number of decimals to show
const PADDING = 2  # number of spaces minimum between fields

str_width(s::AbstractString) = length(s)
str_width(s::Symbol) = length(string(s))
str_width(n::Number) = length(string(n))
str_width(f::Function) = length(string(f))
str_width(b::Bool) = b ? 4 : 5
str_width(c::Char) = 1
str_width(::Missing) = 7

_round(x, n=4) = ismissing(x) ? missing : round(x, digits=n)

function getshowrows(io::IO, x::TS)
    nrow = size(x,1)
    display_rows, _ = displaysize(io)
    display_rows -= 3
    if nrow > display_rows
        row_chunk_size = fld(display_rows-4, 2) - 1
        return (collect(1:row_chunk_size), collect(nrow-row_chunk_size:nrow))
    else
        return (collect(1:nrow), Int[])
    end
end

function getwidths(io::IO, X::TS{V,T}, padding::Int) where {V,T}
    width_index = T==Date ? 10 : 19
    width_values = str_width.(X.fields)
    if V <: Bool
        width_values .= 5
    elseif V <: Number
        @inbounds for j in 1:size(X,2)
            width_values[j] = max(width_values[j], maximum(str_width.(_round.(X.values[:,j], DECIMALS))))
        end
    else
        @inbounds for j in 1:size(X,2)
            width_values[j] = max(width_values[j], maximum(str_width.(X.values[:,j])))
        end
    end
    return width_index + padding, width_values .+ padding
end

hasnegs(x::Vector)::Bool = eltype(x)<:Number ? any(x.<zero(eltype(x))) : false
hasnegs(X::Matrix)::Vector{Bool} = [hasnegs(X[:,j]) for j in 1:size(X,2)]

function show(io::IO, X::TS, padding::Int=PADDING, digits::Int=DECIMALS)::Nothing
    # print summary of data structure
    if (isempty(X))
        print(io, "Empty $(typeof(X))\n")
        return nothing
    else
        print(io, "$(size(X,1))x$(size(X,2)) $(typeof(X)): $(X.index[1]) to $(X.index[end])\n\n")
    end
    # partition rows if data too large
    toprows, bottomrows = getshowrows(io, X)
    negatives = hasnegs(X.values)
    width_index, width_values = getwidths(io, X, padding)
    headerline = [rpad("Index", width_index); [rpad(string(X.fields[j]), width_values[j]) for j in 1:size(X,2)]]
    print(io, join(headerline), '\n')
    if isempty(bottomrows)
        @inbounds for (t, x) in X
            datarow = [
                       rpad(t, width_index);
                       [rpad(string(round(x[j], digits=digits)), width_values[j]) for j in 1:size(X,2)]
                      ]
            print(io, join(datarow), '\n')
        end
    else
        @inbounds for (t, x) in X[toprows]
            datarow = [
                       rpad(t, width_index);
                       [rpad(string(round(x[j], digits=digits)), width_values[j]) for j in 1:size(X,2)]
                      ]
            print(io, join(datarow), '\n')
        end
        print(io, "⋮\n")
        @inbounds for (t, x) in X[bottomrows]
            datarow = [
                       rpad(t, width_index);
                       [rpad(string(round(x[j], digits=digits)), width_values[j]) for j in 1:size(X,2)]
                      ]
            print(io, join(datarow), '\n')
        end
    end
    return nothing
end
