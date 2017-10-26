import Base:setindex!

setindex!{R<:Integer}(x::TS, v, r::R) = x.values[r,:] = v
setindex!{R<:AbstractVector{<:Integer}}(x::TS, v, r::R) = x.values[r,:] = v
setindex!{R<:AbstractVector{<:Integer}}(x::TS, v, r::R, ::Colon) = x.values[r,:] = v

setindex!(x::TS, v, r::Int, c::Int) = x.values[r,c] = v
setindex!(x::TS, v, r::Int, c::Symbol) = x.values[r,x.fields.==c] = v
setindex!(x::TS, v, r::Int, c::AbstractVector{Int}) = x.values[r,c] = v
setindex!(x::TS, v, r::Int, c::AbstractVector{Bool}) = x.values[r,c] = v
setindex!(x::TS, v, r::Int, c::AbstractVector{Symbol}) = x.values[r,map((s)->s in c, x.fields)]

setindex!(x::TS, v, r::AbstractVector{Int}, ::Colon) = x.values[r,:] = v
setindex!(x::TS, v, r::AbstractVector{Int}, c::Int) = x.values[r,c] = v
setindex!(x::TS, v, r::AbstractVector{Int}, c::Symbol) = x.values[r,x.fields.==c] = v
setindex!(x::TS, v, r::AbstractVector{Int}, c::AbstractVector{Int}) = x.values[r,c] = v
setindex!(x::TS, v, r::AbstractVector{Int}, c::AbstractVector{Bool}) = x.values[r,c] = v
setindex!(x::TS, v, r::AbstractVector{Int}, c::AbstractVector{Symbol}) = x.values[r,map((s)->s in c, x.fields)]

setindex!(x::TS, v, r::AbstractVector{Bool}, ::Colon) = x.values[r,:] = v
setindex!(x::TS, v, r::AbstractVector{Bool}, c::Int) = x.values[r,c] = v
setindex!(x::TS, v, r::AbstractVector{Bool}, c::Symbol) = x.values[r,x.fields.==c] = v
setindex!(x::TS, v, r::AbstractVector{Bool}, c::AbstractVector{Int}) = x.values[r,c] = v
setindex!(x::TS, v, r::AbstractVector{Bool}, c::AbstractVector{Bool}) = x.values[r,c] = v
setindex!(x::TS, v, r::AbstractVector{Bool}, c::AbstractVector{Symbol}) = x.values[r,map((s)->s in c, x.fields)]

setindex!(x::TS, v, r::AbstractVector{TimeType}) = x.values[findrows(x.index,r),:] = v
setindex!(x::TS, v, r::AbstractVector{TimeType}, ::Colon) = x.values[findrows(x.index,r),:] = v
setindex!(x::TS, v, r::AbstractVector{TimeType}, c::Int) = x.values[findrows(x.index,r),c] = v
setindex!(x::TS, v, r::AbstractVector{TimeType}, c::Symbol) = x.values[findrows(x.index,r),x.fields.==c] = v
setindex!(x::TS, v, r::AbstractVector{TimeType}, c::AbstractVector{Int}) = x.values[findrows(x.index,r),c] = v
setindex!(x::TS, v, r::AbstractVector{TimeType}, c::AbstractVector{Bool}) = x.values[findrows(x.index,r),c] = v
setindex!(x::TS, v, r::AbstractVector{TimeType}, c::AbstractVector{Symbol}) = x.values[findrows(x.index,r),map((s)->s in c, x.fields)]

setindex!(x::TS, v, r::TimeType) = x.values[findrows(x.index,r),:] = v
setindex!(x::TS, v, r::TimeType, ::Colon) = x.values[findrows(x.index,r),:] = v
setindex!(x::TS, v, r::TimeType, c::Int) = x.values[findrows(x.index,r),c] = v
setindex!(x::TS, v, r::TimeType, c::Symbol) = x.values[findrows(x.index,r),x.fields.==c] = v
setindex!(x::TS, v, r::TimeType, c::AbstractVector{Int}) = x.values[findrows(x.index,r),c] = v
setindex!(x::TS, v, r::TimeType, c::AbstractVector{Bool}) = x.values[findrows(x.index,r),c] = v
setindex!(x::TS, v, r::TimeType, c::AbstractVector{Symbol}) = x.values[findrows(x.index,r),map((s)->s in c, x.fields)]

setindex!(x::TS, v, ::Colon) = x.values[:] = v
setindex!(x::TS, v, ::Colon, ::Colon) = x[:] = v
setindex!(x::TS, v, ::Colon, c::Int) = x.values[:,c] = v
setindex!(x::TS, v, ::Colon, c::AbstractVector{Int}) = x.values[:,c] = v
setindex!(x::TS, v, ::Colon, c::Bool) = x.values[:,c] = v
setindex!(x::TS, v, ::Colon, c::AbstractVector{Bool}) = x.values[:,c] = v
setindex!(x::TS, v, c::Symbol) = x.values[:, x.fields.==c] = v
setindex!(x::TS, v, ::Colon, c::AbstractVector{Symbol}) = x.values[:,map((s)->s in c, x.fields)] = v
setindex!(x::TS, v) = x.values = v

