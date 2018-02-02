global SANITIZE_NAMES = false

function set_sanitize_names_option(value::Bool = false)::Void
    global SANITIZE_NAMES
    SANITIZE_NAMES = value
    return nothing
end

# Find columns in a `TS` object corresponding to the given indexing indicator
findcols{C<:Symbol}(c::C, x::TS)                    = x.fields .== c
findcols{C<:AbstractVector{<:Symbol}}(c::C, x::TS)  = map(sym->sym in c, x.fields)
findcols{C<:Int}(c::C, x::TS)                       = [c]
findcols{C<:AbstractVector{<:Integer}}(c::C, x::TS) = c

# Find rows in a `TS` object corresponding to the given indexing indicator
findrows{T<:AbstractVector{<:TimeType}}(t::T, x::TS) = map(ti->ti in t, x.index)
findrows{T<:TimeType}(t::T, x::TS)                   = x.index .== t
findrows{R<:Int}(r::R, x::TS)                        = [r]
findrows{R<:AbstractVector{<:Integer}}(r::R, x::TS)  = r
findrows{S<:AbstractString}(s::S, x::TS)             = dtidx(s, x.index)

# Find the alphanumeric characters be able to generate sanitized column names (`fields`)
function findalphanum(s::AbstractString, drop_underscores::Bool=false)::Vector{Int}
   if drop_underscores
       return sort(union(find(isalpha,s), find(isnumber,s)))
   else
       return sort(union(union(find(isalpha,s), find(isnumber,s)), find(c->c=='_', s)))
   end
end

# Find the alphanumeric characters be able to generate sanitized column names (`fields`)
findalphanum(s::String)::Vector{Int} = find(isalpha.(split(s,"")).+isnumber.(split(s,"")))

# Change a String or Symbol to an alphanumeric-only version
namefix(s::AbstractString)::AbstractString = s[findalphanum(s)]

# Change a String or Symbol to an alphanumeric-only version
namefix(s::Symbol)::Symbol = Symbol(namefix(string(s)))

# Convert all column names (`field`s) of a TS object to alphanumeric-only `Symbol`s
namefix!(x::TS)::Void = x.fields = namefix.(x.fields)

# Generate automatic column names following the Excel spreadsheet naming convention (A,B,C,..,X,Y,Z,AA,AB,AC,...)
function autocol(col::Int)::Symbol
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
autocol(cols::AbstractArray{Int,1})::Vector{Symbol} = autocol.(cols)

# Automatically generate an `index` vector of `Date`/`DateTime` values from today's date back through $n$ days
autoidx(n::Int; dt::Period=Day(1), from::Date=today()-(n-1)*dt, thru::Date=from+(n-1)*dt) = collect(from:dt:thru)

# default placeholders for singleton types to be replaced by missing's

function default(v::V) where {V<:DataType}
    try
        return v()
    catch
        try
            return zero(v)
        catch
            try
                return eval(parse(lowercase(string(v))))()
            catch
                try
                    return v
                catch
                    error("No viable default method for type $v found.")
                end
            end
        end
    end
end

function clean_values{V}(x::TS{V})::Tuple
    idx_missing = ismissing.(x.values)
    x.values[idx_missing] = default(V)
    cleaned_values = Matrix{V}(x.values)
    x.values[idx_missing] = missing
    return (cleaned_values, idx_missing)
end

# isabstract{V<:DataType}(::V) = isempty(subtypes(T))
