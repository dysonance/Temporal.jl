using Temporal
using DataStreams


struct TemporalStream{V,T}
    data::Tuple{Vector{T}, Vector{Vector{V}}}
    header::Vector{String}
end

TemporalStream{V,T}(X::TS{V,T}) = TemporalStream(Tuple((X.index, collect(X.values[:,j] for j in 1:size(X,2)))),
                                                 string.(X.fields))

function Data.schema{V,T}(X::TS{V,T})
    return Data.Schema([[T]; [eltype(X) for j in 1:size(X,2)]],
                       [["index"]; [string(f) for f in X.fields]],
                       size(X,1))
end

Data.isdone(source::TS, row, col, rows, cols) = row > rows || col > cols
function Data.isdone(source::TS, row, col)
    cols = size(source, 2)
    return Data.isdone(source, row, col, cols == 0 ? 0 : length(source.fields,1), cols)
end

Data.streamtype(::Type{TS}, ::Type{Data.Column}) = true
Data.streamtype(::Type{TS}, ::Type{Data.Field}) = true
Data.streamtypes(::Type{TS}) = [Data.Column, Data.Field]
Data.streamfrom(source::TS, ::Type{Data.Column}, ::Type{T}, row, col) where {T} = source[col].values
Data.streamfrom(source::TS, ::Type{Data.Field}, ::Type{T}, row, col) where {T} = source[row, col].values

