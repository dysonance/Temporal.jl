import Base:setindex!

setindex!(x::TS, v, ::Colon) = x.values[:] = v
setindex!(x::TS, v, ::Colon, ::Colon) = x[:] = v
setindex!(x::TS, v, ::Colon, c) = x.values[:, findcols(c,x)] = v
setindex!(x::TS, v, r, ::Colon) = x.values[findrows(r,x), :] = v
setindex!(x::TS, v, r, c) = x.values[findrows(r,x), findcols(c,x)] = v

setindex!{R<:TimeType}(x::TS, v, r::R) = x.values[findrows(r,x), :] = v
setindex!{R<:AbstractVector{<:TimeType}}(x::TS, v, r::R) = x.values[findrows(r,x), :] = v
setindex!{R<:AbstractString}(x::TS, v, r::R) = x.values[findrows(r,x), :] = v
setindex!{R<:Int}(x::TS, v, r::R) = x.values[findrows(r,x), :] = v
setindex!{R<:AbstractVector{<:Integer}}(x::TS, v, r::R) = x.values[findrows(r,x), :] = v

setindex!{C<:Symbol}(x::TS, v, c::C) = x.values[:, findcols(c,x)] = v
setindex!{C<:AbstractVector{Symbol}}(x::TS, v, c::C) = x.values[:, findcols(c,x)] = v
