import Base: setindex!

setindex!(x::TS, v, ::Colon) = x.values[:] .= v
setindex!(x::TS, v, ::Colon, ::Colon) = x[:] = v
setindex!(x::TS, v, ::Colon, c) = x.values[:, findcols(c,x)] .= v
setindex!(x::TS, v, r, ::Colon) = x.values[findrows(r,x), :] .= v
setindex!(x::TS, v, r, c) = x.values[findrows(r,x), findcols(c,x)] .= v

setindex!(x::TS, v, r::R) where {R<:TimeType} = x.values[findrows(r,x), :] .= v
setindex!(x::TS, v, r::R) where {R<:AbstractVector{<:TimeType}} = x.values[findrows(r,x), :] .= v
setindex!(x::TS, v, r::R) where {R<:AbstractString} = x.values[findrows(r,x), :] .= v
setindex!(x::TS, v, r::R) where {R<:Int} = x.values[findrows(r,x), :] .= v
setindex!(x::TS, v, r::R) where {R<:AbstractVector{<:Integer}} = x.values[findrows(r,x), :] .= v

setindex!(x::TS, v, c::C) where {C<:Symbol} = x.values[:, findcols(c,x)] .= v
setindex!(x::TS, v, c::C) where {C<:AbstractVector{Symbol}} = x.values[:, findcols(c,x)] .= v
