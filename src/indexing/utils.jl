findcolumns{C<:Int}(c::C, ::TS) = [c]
findcolumns{C<:Symbol}(c::C, x::TS) = x.fields .== c
findcolumns{C<:Symbol}(c::AbstractVector{C}, x::TS) = collect(f in c for f=x.fields)

findrows{T<:TimeType}(t::AbstractVector{T}, r::AbstractVector{T})::Vector{Bool} = [ti in r for ti=t]
findrows{T<:TimeType}(t::AbstractVector{T}, r::T)::Vector{Bool} = r.==t
