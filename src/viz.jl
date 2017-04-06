using Plots

isdefined(:X) ? nothing : X = yahoo("XOM")  # Exxon stock
isdefined(:Y) ? nothing : Y = quandl("CHRIS/CME_CL1")  # WTI crude oil
x = cl(X)
y = cl(Y)
x.fields = [:XOM]
y.fields = [:CL1]
dx = diff(log(x))
dy = diff(log(x))
R = [cumprod(1+dx) cumprod(1+dy)]


# @recipe function f(X::TS)
#     x --> X.index
#     y --> X.values
#     lab --> string.(x.fields)
# end
