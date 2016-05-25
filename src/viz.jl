# Conditional supporting packages
importall Plots

function plot(data::TS; lab=[string(fld) for fld=data.fields], args...)
    plot(data.index, data.values, lab=ifelse(length(lab)==1, lab[1], lab); args...)
end
