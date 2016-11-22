const DECIMALS = 4
const SHOWINT = true
const PADDING = 2  # number of spaces minimum between fields

import Base: isinteger, strwidth, rpad
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
strwidth(d::Date)::Int = strwidth(string(d))
strwidth(t::DateTime)::Int = strwidth(string(t))
strwidth(b::Bool)::Int = b ? 4 : 5
strwidth(c::Char)::Int = 1


function show{V,T}(io::IO, x::TS{V,T})
    # If no data, print a simple message verifying emptiness
    if isempty(x)
        @printf(io, "Empty %s", typeof(x))
        return
    end
    int_flds = [all(isinteger.(x.values[:,j])) for j in 1:size(x,2)]  # which fields/columns can be represented as integers
    fldchars = getfldchars(x.values, x.fields) + PADDING  # number of characters (with padding) given to each field/column
    idxchars = strwidth(x.index[1])  + PADDING # number of characters (with padding) given to the index column
    print_summary_line(io, x)
    print_header_row(io, x, fldchars, idxchars)
    print_value_rows(io, x, int_flds, fldchars, idxchars)
    nothing
end


function getfldchars{V}(values::Array{V}, fields::Vector{Symbol})::Vector{Int}
    @assert size(values,2) == size(fields,1)
    fldchars = strwidth.(fields)
    if size(values,1) > 10
        vals = values[[1:5;end-4:end],:]
    end
    @inbounds for j in 1:size(vals,2)
        try
            fldchars[j] = max(fldchars[j], strwidth(@sprintf("%.4f", maximum(vals[:,j]))))
        catch  # for non-numeric cases
            fldchars[j] = max(fldchars[j], maximum(strwidth.(vals[:,j])))
        end
    end
    return fldchars
end
function print_summary_line(io::IO, x::TS)
    @printf(io, "%dx%d %s: %s to %s\n\n", size(x,1), size(x,2), typeof(x), x.index[1], x.index[end])
    nothing
end
function print_header_row(io::IO, x::TS, fldchars::Vector{Int}=getfldchars(x.values, x.fields), idxchars::Int=strwidth(x.index[1]))
    print(io, rpad("Index", idxchars))
    @inbounds for j in 1:size(x,2)
        print(io, rpad(x.fields[j], fldchars[j]))
    end
    print(io, "\n")
    nothing
end
function print_value_rows{V,T}(io::IO, x::TS{V,T},
                               int_flds::Vector{Bool}=[all(isinteger.(x.values[:,j])) for j in 1:size(x,2)],
                               fldchars::Vector{Int}=getfldchars(x.values, x.fields),
                               idxchars::Int=strwidth(x.index[1]))
    nrow = size(x,1)
    ncol = size(x,2)
    if V == Bool  # can save time on unnecessary calculations if eltype is Bool (max char count = 5)
        @inbounds for i in 1:min(5,nrow)
            print(io, rpad(x.index[i], idxchars))
            @inbounds for j in 1:ncol
                print(io, rpad(x.values[i,j], 5))
            end
        end
        nrow > 9 ? println("...") : nothing
        @inbounds for i in max(6,nrow-4):nrow
            print(io, rpad(x.index[i], idxchars))
            @inbounds for j in 1:ncol
                print(io, rpad(x.values[i,j], 5))
            end
        end
    else
        @inbounds for i in 1:min(5,nrow)
            print(io, rpad(x.index[i], idxchars))
            @inbounds for j in 1:ncol
                if int_flds[j] & SHOWINT
                    print(io, rpad(@sprintf("%i", x.values[i,j]), fldchars[j]))
                else
                    try
                        print(io, rpad(round(x.values[i,j], DECIMALS), fldchars[j]))
                    catch
                        print(io, rpad(x.values[i,j], fldchars[j]))
                    end
                end
            end
            print(io, "\n")
        end
        # Print the ellipsis line if at least 10 rows of data
        if nrow > 10
            println("...")
        end
        @inbounds for i in max(6,nrow-4):nrow
            print(io, rpad(x.index[i], idxchars))
            @inbounds for j in 1:ncol
                if int_flds[j] & SHOWINT
                    print(io, rpad(@sprintf("%i", x.values[i,j]), fldchars[j]))
                else
                    try
                        print(io, rpad(round(x.values[i,j], DECIMALS), fldchars[j]))
                    catch
                        print(io, rpad(x.values[i,j], fldchars[j]))
                    end
                end
            end
            print(io, "\n")
        end
    end
    nothing
end
