#=
Methods to simplify the plotting functionality for TS objects.
=#

using RecipesBase

const DEFAULT_COLORS = [:black, :red, :green, :blue, :cyan, :magenta, :orange, :pink]

function beautify_string(s::String;
                         preserve_acronyms::Bool=true,
                         space_before_nums::Bool=true,
                         rm_underscores::Bool=true)
    idx_upper = findall(isuppercase, s)
    out_arr = String[string(s[1])]
    @inbounds for i in 2:length(s)
        if isuppercase(s[i]) && preserve_acronyms && !isuppercase(s[i-1])
            push!(out_arr, " $(s[i])")
        elseif isnumeric(s[i]) && space_before_nums && !isnumeric(s[i-1])
            push!(out_arr, " $(s[i])")
        else
            push!(out_arr, string(s[i]))
        end
    end
    return rm_underscores ? replace(join(out_arr), "_" => "") : join(out_arr)
end

function tslab(flds::Vector{Symbol}; beautify=true, args...)
    arr::Vector{String} = beautify ? beautify_string.(string.(flds); args...) : string.(flds)
    out::Matrix{String} = repeat([""], 1, length(flds))
    @inbounds for i in 1:length(flds)
        out[1,i] = arr[i]
    end
    return out
end

function get_xticks(t::Vector{T};
                    nticks::Int=5,
                    fmt_str::String=(T==Date ? "yyyy-mm-dd" : "yyyy-mm-ddTHH:MM:SS")) where T<:Dates.TimeType
    xticks_idx::Vector{Int} = round.(Int, range(1, stop=size(t,1), length=nticks))
    xticks_lab::Vector{String} = Dates.format.(t[xticks_idx], fmt_str)
    return xticks_idx, xticks_lab
end

@recipe function f(X::TS)
    #x = 1:size(X,1)
    xticks --> get_xticks(X.index)
    label --> tslab(X.fields)
    X.values
end
