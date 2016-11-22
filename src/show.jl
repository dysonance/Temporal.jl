const DECIMALS = 4
const SHOWINT = true

import Base: isinteger, strwidth
isinteger(::String)::Bool = false
isinteger(::Symbol)::Bool = false
isinteger(::Char)::Bool = false
isinteger(::Date)::Bool = false
isinteger(::DateTime)::Bool = false
isinteger(::Function)::Bool = false
#TODO: add any other relevant types that could get caught in the `intcatcher`

strwidth(s::Symbol)::Int = strwidth(string(s))
strwidth(n::Number)::Int = strwidth(string(n))
strwidth(f::Function)::Int = strwidth(string(f))
strwidth(b::Bool)::Int = b ? 4 : 5
strwidth(c::Char)::Int = 1

function getcolwidths{V}(values::Array{V}, fields::Vector{Symbol})::Vector{Int}
    @assert size(values,2) == size(fields,1)
    colwidths = strwidth.(fields)
    @inbounds for j in 1:size(values,2)
        try
            colwidths[j] = max(colwidths[j], strwidth(@sprintf("%.4f", maximum(values[:,j]))))
        catch  # for non-numeric cases
            colwidths[j] = max(colwidths[j], maximum(strwidth.(values[:,j])))
        end
    end
    return colwidths
end

function show{V,T}(io::IO, x::TS{V,T})
    if isempty(x)
        @printf(io, "Empty %s", typeof(x))
        return
    end

    nrow = size(x,1)
    ncol = size(x,2)
    intcatcher = [all(isinteger.(x.values[:,j])) for j in 1:size(x,2)]
    indexwidth = strwidth(string(x.index[1]))
    colwidths = getcolwidths(x.values, x.fields)

    # Summary line
    @printf(io, "%dx%d %s: %s to %s\n\n", nrow, ncol, typeof(x), x.index[1], x.index[end])

    # Field names line
    print(io, rpad("Index", indexwidth+2))
    @inbounds for j = 1:ncol
        print(io, rpad(x.fields[j], colwidths[j]+2))
    end
    println(io, "")

    # Time index & values line
    if nrow > 9
        @inbounds for i = 1:5
            print(io, rpad(x.index[i], indexwidth+2))
            @inbounds for j = 1:ncol
                if V == Bool
                    print(io, rpad(x.values[i,j], colwidths[j]+2))
                else
                    if intcatcher[j] & SHOWINT
                        print(io, rpad(round(Int, x.values[i,j]), colwidths[j]+2))
                    else
                        try
                            print(io, rpad(round(x.values[i,j], DECIMALS), colwidths[j]+2))
                        catch
                            print(io, rpad(x.values[i,j], colwidths[j]+2))
                        end
                    end
                end
            end
            println(io, "")
        end
        println(io, "...")
        @inbounds for i = nrow-4:nrow
            print(io, rpad(x.index[i], indexwidth+2))
            @inbounds for j = 1:ncol
                if V == Bool
                    print(io, rpad(x.values[i,j], colwidths[j]+2))
                else
                    if intcatcher[j] & SHOWINT
                        print(io, rpad(round(Int, x.values[i,j]), colwidths[j]+2))
                    else
                        try
                            print(io, rpad(round(x.values[i,j], DECIMALS), colwidths[j]+2))
                        catch
                            print(io, rpad(x.values[i,j], colwidths[j]+2))
                        end
                    end
                end
            end
            println(io, "")
        end
    else
        @inbounds for i = 1:nrow
            print(io, rpad(x.index[i], indexwidth+2))
            @inbounds for j = 1:ncol
                if V == Bool
                    print(io, x.index[i], " ")
                else
                    if intcatcher[j] & SHOWINT
                        print(io, rpad(round(Int, x.values[i,j]), colwidths[j]+2))
                    else
                        try
                            print(io, rpad(round(x.values[i,j], DECIMALS), colwidths[j]+2))
                        catch
                            print(io, rpad(x.values[i,j], colwidths[j]+2))
                        end
                    end
                end
            end
            println(io, "")
        end
    end
end
