import Base:getindex

# all element indexing
getindex(x::TS)                   = x
getindex(x::TS, ::Colon)          = x
getindex(x::TS, ::Colon, ::Colon) = x

# general interface
getindex(x::TS, r, c)       = (rows=findrows(r,x); cols=findcols(c,x); TS(x.values[rows,cols],x.index[rows],x.fields[cols]))
getindex(x::TS, r, ::Colon) = (rows=findrows(r,x); TS(x.values[rows,:],x.index[rows],x.fields))
getindex(x::TS, ::Colon, c) = (cols=findcols(c,x); TS(x.values[:,cols],x.index,x.fields[cols]))

# types only used to index rows
getindex{R<:Int}(x::TS, r::R)                        = (rows=findrows(r,x); TS(x.values[rows,:],x.index[rows],x.fields))
getindex{R<:AbstractVector{<:Integer}}(x::TS, r::R)  = (rows=findrows(r,x); TS(x.values[rows,:],x.index[rows],x.fields))
getindex{R<:TimeType}(x::TS, r::R)                   = (rows=findrows(r,x); TS(x.values[rows,:],x.index[rows],x.fields))
getindex{R<:AbstractVector{<:TimeType}}(x::TS, r::R) = (rows=findrows(r,x); TS(x.values[rows,:],x.index[rows],x.fields))
getindex{R<:AbstractString}(x::TS, r::R)             = (rows=findrows(r,x); TS(x.values[rows,:],x.index[rows],x.fields))

# types only used to index columns
getindex{C<:Symbol}(x::TS, c::C)                   = (cols=findcols(c,x); TS(x.values[:,cols],x.index,x.fields[cols]))
getindex{C<:AbstractVector{<:Symbol}}(x::TS, c::C) = (cols=findcols(c,x); TS(x.values[:,cols],x.index,x.fields[cols]))

