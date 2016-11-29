const DECIMALS = 4  # the maximum number of decimals to show
const SHOWROWS = 5  # number of rows to print at beginning and end
const PADDING = 2  # number of spaces minimum between fields
const SHOWINT = false  # whether to format integer columns without decimals

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
strwidth(b::Bool)::Int = b ? 4 : 5
strwidth(c::Char)::Int = 1
# strwidth(d::Date)::Int = strwidth(string(d))
# strwidth(t::DateTime)::Int = strwidth(string(t))


function show{V,T}(io::IO, x::TS{V,T})::Void
    # If no data, print a simple message verifying emptiness
    if isempty(x)
        @printf(io, "Empty %s", typeof(x))
        return
    end
    nrow = size(x,1)
    ncol = size(x,2)
    int_flds = [all(isinteger.(x.values[:,j])) for j in 1:size(x,2)]  # which fields/columns can be represented as integers
    idxchars = getidxchars(x)  + PADDING  # number of characters (with padding) given to index column
    fldchars = getfldchars(x) .+ PADDING  # number of characters (with padding) given to each field/column
    # Print the summary line
    @printf(io, "%dx%d %s: %s to %s\n\n", size(x,1), size(x,2), typeof(x), x.index[1], x.index[end])

    # Print the header row
    print(io, rpad("Index", idxchars))
    for j in 1:ncol
        print(io, rpad(x.fields[j], fldchars[j]))
    end
    println(io, "")

    # Print body rows
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
                if SHOWINT && int_flds[j]
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
                if SHOWINT && int_flds[j]
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

getidxchars{V,T}(x::TS{V,T})::Int = (T == Date ? 10 : 19)
function getfldchars(x::TS)::Vector{Int}
    fldchars = strwidth.(x.fields)
    nrow = size(x,1)
    idx = [1:SHOWROWS; nrow-SHOWROWS+1:nrow]
    vals = nrow > SHOWROWS*2 ? x.values[idx,:] : x.values
    @inbounds for j in 1:size(vals,2)
        try
            fldchars[j] = max(fldchars[j], strwidth(@sprintf("%.4f", maximum(vals[:,j]))))
        catch  # for non-numeric cases
            fldchars[j] = max(fldchars[j], maximum(strwidth.(vals[:,j])))
        end
    end
    return fldchars
end
# function print_summary_line(io::IO, x::TS)::Void
#     @printf(io, "%dx%d %s: %s to %s\n\n", size(x,1), size(x,2), typeof(x), x.index[1], x.index[end])
#     nothing
# end
# function print_header_row(io::IO, x::TS, fldchars::Vector{Int}=getfldchars(x), idxchars::Int=getidxchars(x))
#     print(io, rpad("Index", idxchars))
#     @inbounds for j in 1:size(x,2)
#         print(io, rpad(x.fields[j], fldchars[j]))
#     end
#     print(io, "\n")
#     nothing
# end
# function print_value_rows{V,T}(io::IO, x::TS{V,T},
#                                int_flds::Vector{Bool}=[all(isinteger.(x.values[:,j])) for j in 1:size(x,2)],
#                                fldchars::Vector{Int}=getfldchars(x),
#                                idxchars::Int=getidxchars(x))::Void
#     nrow = size(x,1)
#     ncol = size(x,2)
#     if V == Bool  # can save time on unnecessary calculations if eltype is Bool (max char count = 5)
#         @inbounds for i in 1:min(5,nrow)
#             print(io, rpad(x.index[i], idxchars))
#             @inbounds for j in 1:ncol
#                 print(io, rpad(x.values[i,j], 5))
#             end
#         end
#         nrow > 9 ? println("...") : nothing
#         @inbounds for i in max(6,nrow-4):nrow
#             print(io, rpad(x.index[i], idxchars))
#             @inbounds for j in 1:ncol
#                 print(io, rpad(x.values[i,j], 5))
#             end
#         end
#     else
#         @inbounds for i in 1:min(5,nrow)
#             print(io, rpad(x.index[i], idxchars))
#             @inbounds for j in 1:ncol
#                 if SHOWINT && int_flds[j]
#                     print(io, rpad(@sprintf("%i", x.values[i,j]), fldchars[j]))
#                 else
#                     try
#                         print(io, rpad(round(x.values[i,j], DECIMALS), fldchars[j]))
#                     catch
#                         print(io, rpad(x.values[i,j], fldchars[j]))
#                     end
#                 end
#             end
#             print(io, "\n")
#         end
#         # Print the ellipsis line if at least 10 rows of data
#         if nrow > 10
#             println("...")
#         end
#         @inbounds for i in max(6,nrow-4):nrow
#             print(io, rpad(x.index[i], idxchars))
#             @inbounds for j in 1:ncol
#                 if SHOWINT && int_flds[j]
#                     print(io, rpad(@sprintf("%i", x.values[i,j]), fldchars[j]))
#                 else
#                     try
#                         print(io, rpad(round(x.values[i,j], DECIMALS), fldchars[j]))
#                     catch
#                         print(io, rpad(x.values[i,j], fldchars[j]))
#                     end
#                 end
#             end
#             print(io, "\n")
#         end
#     end
#     nothing
# end
