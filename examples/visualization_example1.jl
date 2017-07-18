using Temporal, Indicators

# download historical prices for crude oil futures and subset
X = quandl("CHRIS/CME_CL1")
subset = "2012/"
x = cl(X)[subset]
x.fields[1] = :CrudeFutures

# merge with some technical indicators
D = [x sma(x,n=200) ema(x,n=50)]

# visualize the multivariate time series object
using Plots
plotlyjs()
ℓ = @layout [ a{0.7h}; b{0.3h} ]
plot(D, c=[:black :orange :cyan], w=[4 2 2], layout=ℓ, subplot=1)
plot!(wma(x,n=25), c=:red, w=2, subplot=1)
bar!(X["2012/",:Volume], c=:grey, alpha=0.5, layout=ℓ, subplot=2)

