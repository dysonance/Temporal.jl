import Base:getindex

getindex(x::TS) = x
getindex(x::TS, ::Colon) = x
getindex(x::TS, ::Colon, ::Colon) = x
getindex{C<:Integer}(x::TS, ::Colon, c::C) = TS(x.values[:,c], x.index, x.fields[c])
getindex{C<:Vector{<:Integer}}(x::TS, ::Colon, c::C) = TS(x.values[:,c], x.index, x.fields[c])

getindex{V,T}(x::TS{V,T}, ::Colon)::TS{V,T} = x
getindex{V,T}(x::TS{V,T}, ::Colon, ::Colon)::TS{V,T} = x
getindex{V,T}(x::TS{V,T}, ::Colon, c::Int)::TS{V,T} = ts(x.values[:,c], x.index, [x.fields[c]])
getindex{V,T}(x::TS{V,T}, ::Colon, c::AbstractVector{Int})::TS{V,T} = ts(x.values[:,c], x.index, x.fields[c])

getindex{V,T}(x::TS{V,T}, r::Int)::TS{V,T} = ts(x.values[r,:]', [x.index[r]], x.fields)
getindex{V,T}(x::TS{V,T}, r::Int, ::Colon)::TS{V,T} = ts(x.values[r,:]', [x.index[r]], x.fields)
getindex{V,T}(x::TS{V,T}, r::Int, c::Int)::TS{V,T} = ts([x.values[r,c]], [x.index[r]], [x.fields[c]])
getindex{V,T}(x::TS{V,T}, r::Int, c::AbstractVector{Int})::TS{V,T} = ts(x.values[r,c]', [x.index[r]], x.fields[c])

getindex{V,T}(x::TS{V,T}, r::AbstractVector{Int})::TS{V,T} = ts(x.values[r,:], x.index[r], x.fields)
getindex{V,T}(x::TS{V,T}, r::AbstractVector{Int}, ::Colon)::TS{V,T} = ts(x.values[r,:], x.index[r], x.fields)
getindex{V,T}(x::TS{V,T}, r::AbstractVector{Int}, c::Int)::TS{V,T} = ts(x.values[r,c], x.index[r], [x.fields[c]])
getindex{V,T}(x::TS{V,T}, r::AbstractVector{Int}, c::AbstractVector{Int})::TS{V,T} = ts(x.values[r, c], x.index[r], x.fields[c])

#===============================================================================
							BOOLEAN INDEXING
===============================================================================#
getindex{V,T}(x::TS{V,T}, r::BitArray{1})::TS{V,T} = TS(x.values[r,:], x.index[r], x.fields)
getindex{V,T}(x::TS{V,T}, r::BitArray{1}, ::Colon)::TS{V,T} = TS(x.values[r,:], x.index[r], x.fields)
getindex{V,T}(x::TS{V,T}, r::BitArray{1}, c::Int)::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, r::BitArray{1}, c::AbstractVector{Int})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, r::BitArray{1}, c::BitArray{1})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, r::BitArray{1}, c::Vector{Bool})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])

getindex{V,T}(x::TS{V,T}, r::Vector{Bool})::TS{V,T} = TS(x.values[r,:], x.index[r], x.fields)
getindex{V,T}(x::TS{V,T}, r::Vector{Bool}, ::Colon)::TS{V,T} = TS(x.values[r,:], x.index[r], x.fields)
getindex{V,T}(x::TS{V,T}, r::Vector{Bool}, c::Int)::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, r::Vector{Bool}, c::AbstractVector{Int})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, r::Vector{Bool}, c::Vector{Bool})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, r::Vector{Bool}, c::BitArray{1})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])

getindex{V,T}(x::TS{V,T}, r::AbstractVector{Int}, c::BitArray{1})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, r::AbstractVector{Int}, c::Vector{Bool})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, r::Int, c::BitArray{1})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, r::Int, c::Vector{Bool})::TS{V,T} = TS(x.values[r,c], x.index[r], x.fields[c])
getindex{V,T}(x::TS{V,T}, ::Colon, c::BitArray{1})::TS{V,T} = TS(x.values[:,c], x.index[:], x.fields[c])
getindex{V,T}(x::TS{V,T}, ::Colon, c::Vector{Bool})::TS{V,T} = TS(x.values[:,c], x.index[:], x.fields[c])

getindex{V,T}(x::TS{V,T}, r::TS{Bool})::TS{V,T} = x[r.index[overlaps(r.index,x.index).*r.values]]
getindex{V,T}(x::TS{V,T}, r::TS{Bool}, ::Colon)::TS{V,T} = x[r.index[overlaps(r.index,x.index).*r.values]]
getindex{V,T}(x::TS{V,T}, r::TS{Bool}, c::Int)::TS{V,T} = x[r.index[overlaps(r.index,x.index).*r.values],c]
getindex{V,T}(x::TS{V,T}, r::TS{Bool}, c::AbstractVector{Int})::TS{V,T} = x[r.index[overlaps(r.index,x.index).*r.values],c]
getindex{V,T}(x::TS{V,T}, r::TS{Bool}, c::Vector{Bool})::TS{V,T} = x[r.index[overlaps(r.index,x.index).*r.values],c]
getindex{V,T}(x::TS{V,T}, r::TS{Bool}, c::BitArray{1})::TS{V,T} = x[r.index[overlaps(r.index,x.index).*r.values],c]
getindex{V,T}(x::TS{V,T}, r::TS{Bool}, c::Symbol)::TS{V,T} = x[r.index[overlaps(r.index,x.index).*r.values],c]
getindex{V,T}(x::TS{V,T}, r::TS{Bool}, c::Vector{Symbol})::TS{V,T} = x[r.index[overlaps(r.index,x.index).*r.values],c]

#===============================================================================
							TEMPORAL INDEXING
===============================================================================#
getindex{V,T}(x::TS{V,T}, r::TimeType)::TS{V,T} = x[x.index.==r]
getindex{V,T}(x::TS{V,T}, r::TimeType, ::Colon)::TS{V,T} = x[x.index.==r,:]
getindex{V,T}(x::TS{V,T}, r::TimeType, c::Int)::TS{V,T} = x[x.index.==r,c]
getindex{V,T}(x::TS{V,T}, r::TimeType, c::AbstractVector{Int})::TS{V,T} = x[x.index.==r,c]
getindex{V,T}(x::TS{V,T}, r::TimeType, c::BitArray{1})::TS{V,T} = x[x.index.==r,c]

getindex{V,T}(x::TS{V,T}, r::AbstractArray{Date,1})::TS{V,T} = x[overlaps(x.index, r)]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{Date,1}, ::Colon)::TS{V,T} = x[overlaps(x.index, r), :]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{Date,1}, c::Int)::TS{V,T} = x[overlaps(x.index, r), c]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{Date,1}, c::AbstractVector{Int})::TS{V,T} = x[overlaps(x.index, r), c]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{Date,1}, c::BitArray{1})::TS{V,T} = x[overlaps(x.index, r), c]

getindex{V,T}(x::TS{V,T}, r::AbstractArray{DateTime,1})::TS{V,T} = x[overlaps(x.index, r)]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{DateTime,1}, ::Colon)::TS{V,T} = x[overlaps(x.index, r), :]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{DateTime,1}, c::Int)::TS{V,T} = x[overlaps(x.index, r), c]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{DateTime,1}, c::AbstractVector{Int})::TS{V,T} = x[overlaps(x.index, r), c]
getindex{V,T}(x::TS{V,T}, r::AbstractArray{DateTime,1}, c::BitArray{1})::TS{V,T} = x[overlaps(x.index, r), c]

#===============================================================================
							TEXTUAL INDEXING
===============================================================================#
getindex(x::TS, c::Symbol) = TS(view(x.values, :, x.fields.==c), x.index, c)
#getindex{V,T}(x::TS{V,T}, c::Symbol)::TS{V,T} = x[:, x.fields.==c]
#getindex{V,T}(x::TS{V,T}, c::Vector{Symbol})::TS{V,T} = x[:, overlaps(x.fields, c)]
#
#getindex{V,T}(x::TS{V,T}, ::Colon, c::Symbol)::TS{V,T} = x[:, x.fields.==c]
#getindex{V,T}(x::TS{V,T}, ::Colon, c::Vector{Symbol})::TS{V,T} = x[:, overlaps(x.fields, c)]
#
#getindex{V,T}(x::TS{V,T}, r::Int, c::Symbol)::TS{V,T} = x[r, x.fields.==c]
#getindex{V,T}(x::TS{V,T}, r::Int, c::Vector{Symbol})::TS{V,T} = x[r, overlaps(x.fields, c)]
#
#getindex{V,T}(x::TS{V,T}, r::TimeType, c::Symbol)::TS{V,T} = x[r, x.fields.==c]
#getindex{V,T}(x::TS{V,T}, r::TimeType, c::Vector{Symbol})::TS{V,T} = x[r, overlaps(x.fields, c)]
#
#getindex{V,T}(x::TS{V,T}, r::BitArray{1}, c::Symbol)::TS{V,T} = x[r, x.fields.==c]
#getindex{V,T}(x::TS{V,T}, r::Vector{Bool}, c::Symbol)::TS{V,T} = x[r, x.fields.==c]
#getindex{V,T}(x::TS{V,T}, r::BitArray{1}, c::Vector{Symbol})::TS{V,T} = x[r, overlaps(x.fields, c)]
#getindex{V,T}(x::TS{V,T}, r::Vector{Bool}, c::Vector{Symbol})::TS{V,T} = x[r, overlaps(x.fields, c)]
#
#getindex{V,T}(x::TS{V,T}, r::AbstractVector{Int}, c::Symbol)::TS{V,T} = x[r, x.fields.==c]
#getindex{V,T}(x::TS{V,T}, r::AbstractVector{Int}, c::Vector{Symbol})::TS{V,T} = x[r, overlaps(x.fields, c)]
#getindex{V,T}(x::TS{V,T}, r::AbstractArray{Date,1}, c::Symbol)::TS{V,T} = x[r, x.fields.==c]
#getindex{V,T}(x::TS{V,T}, r::AbstractArray{Date,1}, c::Vector{Symbol})::TS{V,T} = x[r, overlaps(x.fields, c)]
#getindex{V,T}(x::TS{V,T}, r::AbstractArray{DateTime,1}, c::Symbol)::TS{V,T} = x[r, x.fields.==c]
#getindex{V,T}(x::TS{V,T}, r::AbstractArray{DateTime,1}, c::Vector{Symbol})::TS{V,T} = x[r, overlaps(x.fields, c)]
#
#getindex{V,T}(x::TS{V,T}, r::AbstractString)::TS{V,T} = x[dtidx(r, x.index)]
#getindex{V,T}(x::TS{V,T}, r::AbstractString, ::Colon)::TS{V,T} = x[dtidx(r, x.index)]
#getindex{V,T}(x::TS{V,T}, r::AbstractString, c::Int)::TS{V,T} = x[dtidx(r, x.index), c]
#getindex{V,T}(x::TS{V,T}, r::AbstractString, c::AbstractVector{Int})::TS{V,T} = x[dtidx(r, x.index), c]
#getindex{V,T}(x::TS{V,T}, r::AbstractString, c::BitArray{1})::TS{V,T} = x[dtidx(r, x.index), c]
#getindex{V,T}(x::TS{V,T}, r::AbstractString, c::Symbol)::TS{V,T} = x[dtidx(r, x.index), c]
#getindex{V,T}(x::TS{V,T}, r::AbstractString, c::Vector{Symbol})::TS{V,T} = x[dtidx(r, x.index), c]
