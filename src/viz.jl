#=
Methods to simplify the plotting functionality for TS objects.

Plots.jl doesn't support pre-compilation, however, so not making this a dependency yet.
=#

import Plots:
    plot, plot!,
    scatter, scatter!,
    bar, bar!,
    histogram, histogram!

# @recipe function f(X::TS)
#     lab --> (string.(X.fields))'
#     (X.index, X.values)
# end

tslab(X::TS)::Matrix{String} = transpose(string.(X.fields))

plot(X::TS; args...) = plot(X.index, X.values, lab=tslab(X); args...)
plot!(X::TS; args...) = plot!(X.index, X.values, lab=tslab(X); args...)

scatter(X::TS; args...) = scatter(X.index, X.values, lab=tslab(X); args...)
scatter!(X::TS; args...) = scatter!(X.index, X.values, lab=tslab(X); args...)

bar(X::TS; args...) = bar(X.values, lab=tslab(X); args...)
bar!(X::TS; args...) = bar!(X.values, lab=tslab(X); args...)

histogram(X::TS; args...) = histogram(X.values, lab=tslab(X); args...)
histogram!(X::TS; args...) = histogram!(X.values, lab=tslab(X); args...)

