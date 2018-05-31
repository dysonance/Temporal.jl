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

# source
Data.isdone(source::TS, row, col, rows, cols) = row > rows || col > cols
Data.isdone(source::TS, row, col) = Data.isdone(source, row, col, length(source.fields, 1), size(source, 2))
Data.streamtype(::Type{TS}, ::Type{Data.Column}) = true
Data.streamtype(::Type{TS}, ::Type{Data.Field}) = true
Data.streamtypes(::Type{TS}) = [Data.Column, Data.Field]
Data.streamfrom(source::TS, ::Type{Data.Column}, ::Type{T}, row, col) where {T} = source[col].values
Data.streamfrom(source::TS, ::Type{Data.Field}, ::Type{T}, row, col) where {T} = source[row, col].values

# sink
function TS(schema::Data.Schema{R},
            ::Type{S}=Data.Field,
            append::Bool=false,
            args...;
            reference::Vector{UInt8}=UInt8[]) where {R, S<:Data.StreamType}
    types = Data.types(sch)
    rows = (S == Data.Column ? 0 : (!R ? 0 : sch.rows))
    names = Data.header(sch)
    sink = TemporalStream(Tuple(allocate(types[i], rows, reference) for i in 1:length(types)), names)
    return sink
end

Data.close!(stream::TemporalStream) = TS(hcat(stream.data[2][j] for j in 1:length(stream.data[2])),
                                         stream.data[1],
                                         Symbol.(stream.header))

TS(x::TS) = TS(x.values, x.index, x.fields)
