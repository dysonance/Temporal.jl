findcolumns{C<:Int}(c::C, ::TS) = [c]
findcolumns{C<:Symbol}(c::C, x::TS) = x.fields .== c
findcolumns{C<:Symbol}(c::AbstractVector{C}, x::TS) = collect(f in c for f=x.fields)

