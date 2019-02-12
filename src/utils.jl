global SANITIZE_NAMES = false

function set_sanitize_names_option(value::Bool = false)
    global SANITIZE_NAMES
    SANITIZE_NAMES = value
    return nothing
end

# Find columns in a `TS` object corresponding to the given indexing indicator
findcols(c::C, x::TS) where {C<:Symbol} = x.fields .== c
findcols(c::C, x::TS) where {C<:AbstractVector{<:Symbol}} = vcat([findall(c .== x.fields) for c in c]...)
findcols(c::C, x::TS) where {C<:Int} = [c]
findcols(c::C, x::TS) where {C<:AbstractVector{<:Integer}} = c

# Find rows in a `TS` object corresponding to the given indexing indicator
findrows(t::T, x::TS) where {T<:AbstractVector{<:TimeType}} = map(ti->ti in t, x.index)
findrows(t::T, x::TS) where {T<:TimeType} = x.index .== t
findrows(r::R, x::TS) where {R<:Int} = [r]
findrows(r::R, x::TS) where {R<:AbstractVector{<:Integer}} = r
findrows(s::S, x::TS) where {S<:AbstractString} = dtidx(s, x.index)

isalphanum(s::String, allow_underscores::Bool=false) = [isletter(c) || isnumeric(c) || (allow_underscores && c=='_') for c in s]

# Find the alphanumeric characters be able to generate sanitized column names (`fields`)
findalphanum(s::String, allow_underscores::Bool=false)::Vector{Int} = findall(isalphanum(s, allow_underscores))

# Change a String or Symbol to an alphanumeric-only version
namefix(s::AbstractString)::AbstractString = s[findalphanum(s)]

# Change a String or Symbol to an alphanumeric-only version
namefix(s::Symbol)::Symbol = Symbol(namefix(string(s)))

# Convert all column names (`field`s) of a TS object to alphanumeric-only `Symbol`s
namefix!(x::TS)::Nothing = x.fields = namefix.(x.fields)

# Generate automatic column names following the Excel spreadsheet naming convention (A,B,C,..,X,Y,Z,AA,AB,AC,...)
function autocol(col::Int)
    @assert col >= 1 "Invalid column number $col - cannot generate column name"
    if col <= 26
        return Symbol(Char(64 + col))
    end
    colname = ""
    modulo = 0
    dividend = col
    while dividend > 0
        modulo = (dividend - 1) % 26
        colname = string(Char(65 + modulo)) * colname
        dividend = Int(round((dividend - modulo) / 26))
    end
    return Symbol(colname)
end
autocol(cols::AbstractArray{Int,1}) = autocol.(cols)

# Automatically generate an `index` vector of `Date`/`DateTime` values from today's date back through $n$ days
autoidx(n::Int; dt::Period=Day(1), from::Date=today()-(n-1)*dt, thru::Date=from+(n-1)*dt) = collect(from:dt:thru)


# function overlaps(x::AbstractArray, y::AbstractArray, n::Int=1)::Vector{Bool}
#     @assert n == 1 || n == 2
#     if n == 1
#         xx = falses(x)
#         @inbounds for i = 1:size(x,1), j = 1:size(y,1)
#             if x[i] == y[j]
#                 xx[i] = true
#             end
#         end
#         return xx
#     elseif n == 2
#         yy = falses(y)
#         @inbounds for i = 1:size(x,1), j = 1:size(y,1)
#             if x[i] == y[j]
#                 yy[i] = true
#             end
#         end
#         return yy
#     end
# end
