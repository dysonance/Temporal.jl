#=
Methods to simplify the plotting functionality for TS objects.
=#

const DEFAULT_COLORS = [:black, :red, :green, :blue, :cyan, :magenta, :orange, :pink]

import RecipesBase: @recipe

function beautify_string(s::String;
                         preserve_acronyms::Bool=true,
                         space_before_nums::Bool=true,
                         rm_underscores::Bool=true)::String
    idx_upper = find(isupper, s)
    out_arr = String[string(s[1])]
    @inbounds for i in 2:length(s)
        if isupper(s[i]) && preserve_acronyms && !isupper(s[i-1])
            push!(out_arr, " $(s[i])")
        elseif isnumber(s[i]) && space_before_nums && !isnumber(s[i-1])
            push!(out_arr, " $(s[i])")
        else
            push!(out_arr, string(s[i]))
        end
    end
    return rm_underscores ? replace(join(out_arr), "_", "") : join(out_arr)
end

function tslab(flds::Vector{Symbol}; beautify=true, args...)::Matrix{String}
    arr::Vector{String} = beautify ? beautify_string.(string.(flds); args...) : string.(flds)
    out::Matrix{String} = repmat([""], 1, length(flds))
    @inbounds for i in 1:length(flds)
        out[1,i] = arr[i]
    end
    return out
end

function get_xticks(t::Vector{T};
                    nticks::Int=5,
                    fmt_str::String=(T==Date ? "yyyy-mm-dd" : "yyyy-mm-ddTHH:MM:SS"))::Tuple{Vector{Int},Vector{String}} where T<:Dates.TimeType
    xticks_idx::Vector{Int} = round.(Int, linspace(1, size(t,1), nticks))
    xticks_lab::Vector{String} = Dates.format.(t[xticks_idx], fmt_str)
    return xticks_idx, xticks_lab
end

@recipe function f(X::TS)
    #x = 1:size(X,1)
    xticks --> get_xticks(X.index)
    lab --> tslab(X.fields)
    X.values
end

