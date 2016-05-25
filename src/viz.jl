# Conditional supporting packages
pkglist(dir::AbstractString=Pkg.dir()) = setdiff(readdir(dir), [".cache","METADATA","META_BRANCH","REQUIRE"])
isinstalled(pkg::AbstractString; dir::AbstractString=Pkg.dir()) = pkg in pkglist(dir)

importall Plots
if isinstalled("PyPlot")
    pyplot(reuse=true)
elseif isinstalled("Gadfly")
    gadfly()
elseif isinstalled("Plotly")
    plotly()
elseif isinstalled("GR")
    gr()
else
    error("No valid backend packages installed.")
end

function plot(X::TS; lab=[string(fld) for fld=data.fields], args...)
    plot(X.index, X.values, lab=ifelse(length(lab)==1, lab[1], lab); args...)
end
