# column finding
findcols{C<:Symbol}(c::C, x::TS)                    = x.fields .== c
findcols{C<:AbstractVector{<:Symbol}}(c::C, x::TS)  = map(sym->sym in c, x.fields)
findcols{C<:Int}(c::C, x::TS)                       = [c]
findcols{C<:AbstractVector{<:Integer}}(c::C, x::TS) = c

# row finding
findrows{T<:AbstractVector{<:TimeType}}(t::T, x::TS) = map(ti->ti in t, x.index)
findrows{T<:TimeType}(t::T, x::TS)                   = x.index .== t
findrows{R<:Int}(r::R, x::TS)                        = [r]
findrows{R<:AbstractVector{<:Integer}}(r::R, x::TS)  = r
findrows{S<:AbstractString}(s::S, x::TS)             = dtidx(s, x.index)

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
