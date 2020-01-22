import Base: getindex, setindex!, axes

axes(x::TS) = axes(x.values)
axes(x::TS, d) = axes(x.values, d)

# all element indexing
getindex(x::TS) = x
getindex(x::TS, ::Colon) = x
getindex(x::TS, ::Colon, ::Colon) = x

# cartesian index support
getindex(x::TS, idx::CartesianIndex{2}) = x.values[idx.I[1], idx.I[2]]
getindex(x::TS, idx::CI) where {CI<:AbstractArray{CartesianIndex{2}}} = TS(x.values[idx],
                                                                           x.index[[idx[i].I[1] for i in 1:length(idx)]],
                                                                           x.fields[unique([idx[i].I[2] for i in 1:length(idx)])])

# general interface
getindex(x::TS, r, c) = (rows=findrows(r,x); cols=findcols(c,x); TS(x.values[rows,cols],x.index[rows],x.fields[cols]))
getindex(x::TS, r, ::Colon) = (rows=findrows(r,x); TS(x.values[rows,:],x.index[rows],x.fields))
getindex(x::TS, ::Colon, c) = (cols=findcols(c,x); TS(x.values[:,cols],x.index,x.fields[cols]))

# types only used to index rows
getindex(x::TS, r::R) where {R<:Int} = (rows=findrows(r,x); TS(x.values[rows,:],x.index[rows],x.fields))
getindex(x::TS, r::R) where {R<:AbstractVector{<:Integer}} = (rows=findrows(r,x); TS(x.values[rows,:],x.index[rows],x.fields))
getindex(x::TS, r::R) where {R<:TimeType} = (rows=findrows(r,x); TS(x.values[rows,:],x.index[rows],x.fields))
getindex(x::TS, r::R) where {R<:AbstractVector{<:TimeType}} = (rows=findrows(r,x); TS(x.values[rows,:],x.index[rows],x.fields))
getindex(x::TS, r::R) where {R<:AbstractString} = (rows=findrows(r,x); TS(x.values[rows,:],x.index[rows],x.fields))

# types only used to index columns
getindex(x::TS, c::C) where {C<:Symbol} = (cols=findcols(c,x); TS(x.values[:,cols],x.index,x.fields[cols]))
getindex(x::TS, c::C) where {C<:AbstractVector{<:Symbol}} = (cols=findcols(c,x); TS(x.values[:,cols],x.index,x.fields[cols]))

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

# single column
makecolumns(x::TS, v::V, c::C) where {V<:VALARR, C<:FLDTYPE} = TS(v, x.index, [c])
makecolumns(x::TS, v::V, c::C) where {V<:TS, C<:FLDTYPE} = TS(v.values, x.index, [c])
makecolumns(x::TS, v::V, c::C) where {V<:VALTYPE, C<:FLDTYPE} = TS(zeros(typeof(v), size(x,1)).+v, x.index, [c])
# multiple columns
makecolumns(x::TS, v::V, c::C) where {V<:VALARR, C<:FLDARR} = TS(v, x.index, c)
makecolumns(x::TS, v::V, c::C) where {V<:TS, C<:FLDARR} = TS(v.values, x.index, c)

# column modification/addition via e.g. X[:Column] = randn(N)
function setindex!(x::TS, v::V, c::C) where {V<:Union{<:VALARR,VALTYPE,TS},C<:Union{AbstractVector{Symbol},Symbol}}
    found = sum(findcols(c,x)) > 0
    if found
        x.values[:, findcols(c,x)] .= v
    else
        y = [x makecolumns(x, v, c)]
        x.values = y.values
        x.fields = y.fields
    end
end
