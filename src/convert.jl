using Temporal, Dates

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
