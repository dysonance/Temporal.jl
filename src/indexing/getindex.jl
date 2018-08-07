import Base.getindex

# define axes function for newer julia versions
if VERSION >= v"0.7-"
    import Base.axes
    axes(x::TS) = axes(x.values)
    axes(x::TS, d) = axes(x.values, d)
end

# all element indexing
getindex(x::TS) = x
getindex(x::TS, ::Colon) = x
getindex(x::TS, ::Colon, ::Colon) = x

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

