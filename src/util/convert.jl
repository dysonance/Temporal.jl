# constructors
TS(v::AbstractArray{V}, t::AbstractVector{T}, f::Union{Symbol,String,Char}) where {V,T} = TS{V,T}(v, t, [Symbol(f)])
TS(v::AbstractArray{V}, t::AbstractVector{T}, f::Union{AbstractVector{Symbol},AbstractVector{String},AbstractVector{Char}}) where {V,T} = TS{V,T}(v, t, Symbol.(f))
TS(v::AbstractArray{V}, t::AbstractVector{T}) where {V,T} = TS{V,T}(v, t, autocol(1:size(v,2)))
TS(v::AbstractArray{V}, t::T, f) where {V,T} = TS{V,T}(v, [t], f)
TS(v::V, t::AbstractVector{T}, f) where {V,T} = TS{V,T}([v], t, f)
TS(v::V, t::T, f) where {V,T} = TS{V,T}([v][:,:], [t], f)
TS(v::V, t::T) where {V,T} = TS{V,T}([v], [t], [:A])
TS(v::AbstractArray{V}) where {V} = TS{V,Date}(v, autoidx(size(v,1)), autocol(1:size(v,2)))
TS() = TS{Float64,Date}(Matrix{Float64}(UndefInitializer(),0,0), Date[], Symbol[])
TS(X::TS) = TS(X.values, X.index, X.fields)

function find_index_col(fields)::Int
    regex = r"date|time|index"i
    @inbounds for (j, field) in enumerate(fields)
        if occursin(regex, String(field))
            return j
        end
    end
    return 0
end

function TS(named_tuple::NamedTuple, index_element::Int=find_index_col(keys(named_tuple)))::TS
    index = named_tuple[index_element]
    array = zeros(Float64, (length(index), length(named_tuple)-1))
    value_elements = setdiff(1:length(named_tuple), index_element)
    fields = [f for f in keys(named_tuple)[value_elements]]
    @inbounds for (array_col, tuple_element) in enumerate(value_elements)
        array[:,array_col] = Real.(named_tuple[tuple_element])
    end
    return TS(array, index, fields)
end

# conversions
convert(::Type{TS{Float64}}, x::TS{Bool}) = TS{Float64}(map(Float64, x.values), x.index, x.fields)
convert(::Type{TS{Int}}, x::TS{Bool}) = TS{Int}(map(Int, x.values), x.index, x.fields)
convert(::Type{TS{Bool}}, x::TS{V}) where {V<:Real} = TS{Bool}(map(V, x.values), x.index, x.fields)
convert(x::TS{Bool}) = convert(TS{Int}, x::TS{Bool})
