# constructors

# values array + index array + fields singleton
TS(v::V, t::T, f::F) where {V<:VALARR,T<:IDXARR,F<:FLDTYPE} = TS(collect(hcat(v)), collect(t), [Symbol(f)])

# values array + index array + fields array
TS(v::V, t::T, f::F) where {V<:VALARR,T<:IDXARR,F<:FLDARR} = TS(collect(hcat(v)), collect(t), Symbol.(f))

# values array + index array
TS(v::V, t::T) where {V<:VALARR,T<:IDXARR} = TS(collect(hcat(v)), collect(t), autocol(1:size(v,2)))

# values array + index singleton + fields any
TS(v::V, t::T, f) where {V<:VALARR,T<:IDXTYPE} = TS(collect(hcat(v)), [t], f)

# values singleton + index array + fields any
TS(v::V, t::T, f) where {V<:VALTYPE,T<:IDXARR} = TS([v], collect(t), f)

# values singleton + index singelton + fields any
TS(v::V, t::T, f) where {V<:VALTYPE,T<:IDXTYPE} = TS([v][:,:], [t], f)

# values singleton + index array
TS(v::V, t::T) where {V<:VALTYPE, T<:IDXARR} = TS([v], collect(t), [:A])

# values singleton + index singleton
TS(v::V, t::T) where {V<:VALTYPE, T<:IDXTYPE} = TS([v], [t], [:A])

# values array
TS(v::V) where {V<:VALARR} = TS(collect(v), autoidx(size(v,1)), autocol(1:size(v,2)))

# default constructor
TS() = TS(zeros((0,0)), Date[], Symbol[])

# copy constructor
TS(X::TS) = copy(X)

# named tuple constructor
function TS(named_tuple::NamedTuple, index_element::Int=0)::TS
    function find_index_col(fields)::Int
        regex = r"date|time|index"i
        @inbounds for (j, field) in enumerate(fields)
            if occursin(regex, String(field))
                return j
            end
        end
        return 0
    end
    if index_element == 0
        index_element = find_index_col(keys(named_tuple))
    end
    index = named_tuple[index_element]
    array = zeros(Float64, (length(index), length(named_tuple)-1))
    value_elements = setdiff(1:length(named_tuple), index_element)
    fields = [f for f in keys(named_tuple)[value_elements]]
    @inbounds for (array_col, tuple_element) in enumerate(value_elements)
        array[:,array_col] = VALTYPE.(named_tuple[tuple_element])
    end
    return TS(array, index, fields)
end

# conversions

# boolean -> numeric
convert(::Type{TS{Bool}}, x::TS{V}) where {V<:VALTYPE} = TS{Bool}(map(V, x.values), x.index, x.fields)

## boolean -> float
#convert(::Type{TS{Float64}}, x::TS{Bool}) = TS{Float64}(map(Float64, x.values), x.index, x.fields)
#
## boolean -> integer
#convert(::Type{TS{Int}}, x::TS{Bool}) = TS{Int}(map(Int, x.values), x.index, x.fields)
