VERSION >= v"0.4.0" && __precompile__(true)

module Temporal
using Base.Dates

# pkglist(dir::AbstractString=Pkg.dir()) = setdiff(readdir(dir), [".cache","METADATA","META_BRANCH","REQUIRE"])
# isinstalled(pkg::AbstractString; dir::AbstractString=Pkg.dir()) = pkg in pkglist(dir)
# if isinstalled("PyPlot")
#     pyplot(reuse=true)
# elseif isinstalled("Gadfly")
#     gadfly()
# elseif isinstalled("Plotly")
#     plotly()
# elseif isinstalled("GR")
#     gr()
# else
#     error("No valid backend packages installed.")
# end

export
    TS, ts, size, overlaps,
    ojoin, ijoin, ljoin, rjoin, merge, hcat, vcat, head, tail,
    nanrows, nancols, dropnan, fillnan, fillnan!, ffill!, bfill!, linterp!,
    numfun, arrfun, op,
    ones, zeros, trues, falses, isnan, countnz,
    sum, mean, maximum, minimum, prod, cumsum, cumprod, diff, lag, nans,
    mondays, tuesdays, wednesdays, thursdays, fridays, saturdays, sundays, 
    bow, eow, bom, eom, boq, eoq, boy, eoy,
<<<<<<< HEAD
    toweekly, tomonthly, toquarterly, toyearly, collapse,
    tsread, tswrite
=======
    toweekly, tomonthly, toquarterly, toyearly, aggregate,
    tsread, tswrite,
    plot
>>>>>>> ef67b2d045d26f73cf69869798d72efd8fa43b5b

include("ts.jl")
include("indexing.jl")
include("combine.jl")
include("collapse.jl")
include("operations.jl")
include("slice.jl")
include("io.jl")
# include("viz.jl")

end # module
