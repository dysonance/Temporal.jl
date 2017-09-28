import Base:setindex!

setindex!(x::TS, v, r::Int) = x.values[r,:] = v
setindex!(x::TS, v, r::Int, ::Colon) = x.values[r,:] = v
setindex!(x::TS, v, r::Int, c::Int) = x.values[r,c] = v
setindex!(x::TS, v, r::Int, c::Symbol) = x.values[r,find(x.fields.==c)] = v
setindex!(x::TS, v, r::Int, c::AbstractVector{Int}) = x.values[r,c] = v
setindex!(x::TS, v, r::Int, c::AbstractVector{Bool}) = x.values[r,c] = v
setindex!(x::TS, v, r::Int, c::AbstractVector{Symbol}) = x.values[r,map((s)->s in c, x.fields)]

setindex!(x::TS, v, r::AbstractVector{Int}) = x.values[r,:] = v
setindex!(x::TS, v, r::AbstractVector{Int}, ::Colon) = x.values[r,:] = v
setindex!(x::TS, v, r::AbstractVector{Int}, c::Int) = x.values[r,c] = v
setindex!(x::TS, v, r::AbstractVector{Int}, c::Symbol) = x.values[r,find(x.fields.==c)] = v
setindex!(x::TS, v, r::AbstractVector{Int}, c::AbstractVector{Int}) = x.values[r,c] = v
setindex!(x::TS, v, r::AbstractVector{Int}, c::AbstractVector{Bool}) = x.values[r,c] = v
setindex!(x::TS, v, r::AbstractVector{Int}, c::AbstractVector{Symbol}) = x.values[r,map((s)->s in c, x.fields)]

setindex!(x::TS, v, r::AbstractVector{Bool}) = x.values[r,:] = v
setindex!(x::TS, v, r::AbstractVector{Bool}, ::Colon) = x.values[r,:] = v
setindex!(x::TS, v, r::AbstractVector{Bool}, c::Int) = x.values[r,c] = v
setindex!(x::TS, v, r::AbstractVector{Bool}, c::Symbol) = x.values[r,find(x.fields.==c)] = v
setindex!(x::TS, v, r::AbstractVector{Bool}, c::AbstractVector{Int}) = x.values[r,c] = v
setindex!(x::TS, v, r::AbstractVector{Bool}, c::AbstractVector{Bool}) = x.values[r,c] = v
setindex!(x::TS, v, r::AbstractVector{Bool}, c::AbstractVector{Symbol}) = x.values[r,map((s)->s in c, x.fields)]

findrows{T<:TimeType}(t::AbstractVector{T}, r::AbstractVector{T})::Vector{Bool} = [ti in r for ti=t]
setindex!(x::TS, v, r::AbstractVector{TimeType}) = x.values[findrows(x.index,r),:] = v
setindex!(x::TS, v, r::AbstractVector{TimeType}, ::Colon) = x.values[findrows(x.index,r),:] = v
setindex!(x::TS, v, r::AbstractVector{TimeType}, c::Int) = x.values[findrows(x.index,r),c] = v
setindex!(x::TS, v, r::AbstractVector{TimeType}, c::Symbol) = x.values[findrows(x.index,r),find(x.fields.==c)] = v
setindex!(x::TS, v, r::AbstractVector{TimeType}, c::AbstractVector{Int}) = x.values[findrows(x.index,r),c] = v
setindex!(x::TS, v, r::AbstractVector{TimeType}, c::AbstractVector{Bool}) = x.values[findrows(x.index,r),c] = v
setindex!(x::TS, v, r::AbstractVector{TimeType}, c::AbstractVector{Symbol}) = x.values[findrows(x.index,r),map((s)->s in c, x.fields)]

findrows{T<:TimeType}(t::AbstractVector{T}, r::T)::Vector{Bool} = r.==t
setindex!(x::TS, v, r::TimeType) = x.values[findrows(x.index,r),:] = v
setindex!(x::TS, v, r::TimeType, ::Colon) = x.values[findrows(x.index,r),:] = v
setindex!(x::TS, v, r::TimeType, c::Int) = x.values[findrows(x.index,r),c] = v
setindex!(x::TS, v, r::TimeType, c::Symbol) = x.values[findrows(x.index,r),find(x.fields.==c)] = v
setindex!(x::TS, v, r::TimeType, c::AbstractVector{Int}) = x.values[findrows(x.index,r),c] = v
setindex!(x::TS, v, r::TimeType, c::AbstractVector{Bool}) = x.values[findrows(x.index,r),c] = v
setindex!(x::TS, v, r::TimeType, c::AbstractVector{Symbol}) = x.values[findrows(x.index,r),map((s)->s in c, x.fields)]

setindex!(x::TS, v, ::Colon) = x.values = v
setindex!(x::TS, v, ::Colon, ::Colon) = x.values = v
setindex!(x::TS, v) = x.values = v

