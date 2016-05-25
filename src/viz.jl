# Conditional supporting packages
pkglist(dir::AbstractString=Pkg.dir()) = setdiff(readdir(dir), [".cache","METADATA","META_BRANCH","REQUIRE"])
isinstalled(pkg::AbstractString; dir::AbstractString=Pkg.dir()) = pkg in pkglist(dir)

importall Plots
if isinstalled("PyPlot")
    using PyPlot
    pyplot(reuse=true)
elseif isinstalled("Gadfly")
    using Gadfly
    gadfly()
elseif isinstalled("Plotly")
    using Plotly
    plotly()
elseif isinstalled("GR")
    using GR
    gr()
else
    error("No valid backend packages installed.")
end

function plot(X::TS; lab=[string(fld) for fld=data.fields], args...)
    plot(X.index, X.values, lab=ifelse(length(lab)==1, lab[1], lab); args...)
end
