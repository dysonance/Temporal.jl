#=
Utilities for combining and manipulating TS objects using their indexes
=#

function merge{V,T}(x::TS{V,T}, y::TS{V,T}; join::ByteString="outer")
	@assert join in ["outer", "inner", "left", "right"] "Argument `join` must be \"outer\", \"inner\", \"left\", or \"right\"."
end

function matchdates()
end
