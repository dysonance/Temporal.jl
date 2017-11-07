import Base:getindex

# all element indexing
getindex(x::TS) =
    x
getindex(x::TS, ::Colon) =
    x
getindex(x::TS, ::Colon, ::Colon) =
    x

# int/bool row indexing
getindex{R<:Int,V,T}(x::TS{V,T}, r::R) =
    x[[r]]
getindex{R<:Int,V,T}(x::TS{V,T}, r::R, ::Colon) =
    TS((x.values[r,:][:,:]'), x.index[r], x.fields)
getindex{R<:Integer,V,T}(x::TS{V,T}, r::AbstractVector{R}) =
    TS(x.values[r,:], x.index[r], x.fields)
getindex{R<:Integer,V,T}(x::TS{V,T}, r::AbstractVector{R}, ::Colon) =
    TS(x.values[r,:], x.index[r], x.fields)

# int/bool column indexing
getindex{C<:Int}(x::TS, ::Colon, c::C) =
    TS(x.values[:,[c]], x.index, x.fields[c])
getindex{C<:Integer,V,T}(x::TS{V,T}, ::Colon, c::AbstractVector{C}) =
    TS(x.values[:,c], x.index, x.fields[c])

# row+column indexing
getindex{R<:Int,C<:Int,V}(x::TS{V}, r::R, c::C)::V =
    x.values[r,c]
getindex{R<:Int,C<:Integer,V,T}(x::TS{V,T}, r::R, c::AbstractVector{C}) =
    TS(x.values[[r],c], x.index[[r]], x.fields[c])
getindex{R<:Integer,C<:Int,V,T}(x::TS{V,T}, r::AbstractVector{R}, c::C) =
    TS(x.values[r,[c]], x.index[r], [x.fields[c]])
getindex{R<:Integer,C<:Integer,V,T}(x::TS{V,T}, r::AbstractVector{R}, c::AbstractVector{C}) =
    TS(x.values[r,c], x.index[r], x.fields[c])

# symbol column indexing
getindex{C<:AbstractVector{Symbol}}(x::TS, c::C) =
    x[:,overlaps(x.fields,c)]
getindex{C<:AbstractVector{Symbol}}(x::TS, ::Colon, c::C) =
    x[c]
getindex{C<:Symbol}(x::TS, c::C) =
    x[:, x.fields.==c]
getindex{C<:Symbol}(x::TS, ::Colon, c::C) =
    x[c]
getindex{C<:AbstractVector{<:Symbol}}(x::TS, c::C) =
    x[:, overlaps(x.fields, c)]
getindex{C<:AbstractVector{<:Symbol}}(x::TS, ::Colon, c::C) =
    x[c]
getindex{R<:Integer,C<:Symbol,V}(x::TS{V}, r::R, c::C)::V =
    x.values[r, findfirst(x.fields.==c)]
getindex{R<:Integer,C<:AbstractVector{<:Symbol}}(x::TS, r::R, c::C) =
    x[r, overlaps(x.fields, c)]
getindex{R<:AbstractVector{<:Integer},C<:Symbol}(x::TS, r::R, c::C) =
    x[r, x.fields.==c]
getindex{R<:AbstractVector{<:Integer},C<:AbstractVector{<:Symbol}}(x::TS, r::R, c::C) =
    x[r, overlaps(x.fields, c)]

# timetype row indexing
getindex{V,T<:TimeType}(x::TS{V,T}, t::T) =
    x[x.index.==t]
getindex{V,T<:TimeType}(x::TS{V,T}, t::T, ::Colon) =
    x[x.index.==t,:]
getindex{V,T<:TimeType,C<:Int}(x::TS{V,T}, t::T, c::C) =
    x[x.index.==t,c]
getindex{V,T<:TimeType,C<:Symbol}(x::TS{V,T}, t::T, c::C) =
    x[x.index.==t,c]
getindex{V,T<:TimeType,C<:AbstractVector{<:Integer}}(x::TS{V,T}, t::T, c::C) =
    x[x.index.==t,c]
getindex{V,T<:TimeType,C<:AbstractVector{<:Symbol}}(x::TS{V,T}, t::T, c::C) =
    x[x.index.==t,c]
getindex{V,T<:TimeType}(x::TS{V,T}, t::AbstractVector{T}) =
    x[overlaps(x.index,t)]
getindex{V,T<:TimeType}(x::TS{V,T}, t::AbstractVector{T}, ::Colon) =
    x[overlaps(x.index,t),:]
getindex{V,T<:TimeType,C<:Int}(x::TS{V,T}, t::AbstractVector{T}, c::C) =
    x[overlaps(x.index,t),c]
getindex{V,T<:TimeType,C<:Symbol}(x::TS{V,T}, t::AbstractVector{T}, c::C) =
    x[overlaps(x.index,t),c]
getindex{V,T<:TimeType,C<:AbstractVector{<:Integer}}(x::TS{V,T}, t::AbstractVector{T}, c::C) =
    x[overlaps(x.index,t),c]
getindex{V,T<:TimeType,C<:AbstractVector{<:Symbol}}(x::TS{V,T}, t::AbstractVector{T}, c::C) =
    x[overlaps(x.index,t),c]

# string-based date(time) row indexing
getindex{R<:AbstractString}(x::TS, r::R) =
    x[dtidx(r, x.index)]
getindex{R<:AbstractString}(x::TS, r::R, ::Colon) =
    x[r]
getindex{R<:AbstractString,C<:Int}(x::TS, r::R, c::C) =
    x[dtidx(r, x.index), c]
getindex{R<:AbstractString,C<:AbstractVector{<:Integer}}(x::TS, r::R, c::C) =
    x[dtidx(r, x.index), c]
getindex{R<:AbstractString,C<:Symbol}(x::TS, r::R, c::C) =
    x[dtidx(r, x.index), c]
getindex{R<:AbstractString,C<:AbstractVector{<:Symbol}}(x::TS, r::R, c::C) =
    x[dtidx(r, x.index), c]
