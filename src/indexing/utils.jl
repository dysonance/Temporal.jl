findcolumns{C<:Symbol}(c::C, x::TS) = x.fields .== c
findcolumns{C<:Symbol}(c::AbstractVector{C}, x::TS) = collect(f in c for f=x.fields)

findrows{T<:TimeType}(t::AbstractVector{T}, r::AbstractVector{T})::Vector{Bool} = [ti in r for ti=t]
findrows{T<:TimeType}(t::AbstractVector{T}, r::T)::Vector{Bool} = r.==t

function overlaps(x::AbstractArray, y::AbstractArray, n::Int=1)::Vector{Bool}
    @assert n == 1 || n == 2
    if n == 1
        xx = falses(x)
        @inbounds for i = 1:size(x,1), j = 1:size(y,1)
            if x[i] == y[j]
                xx[i] = true
            end
        end
        return xx
    elseif n == 2
        yy = falses(y)
        @inbounds for i = 1:size(x,1), j = 1:size(y,1)
            if x[i] == y[j]
                yy[i] = true
            end
        end
        return yy
    end
end
