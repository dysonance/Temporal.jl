[![Build Status](https://travis-ci.org/dysonance/Temporal.jl.svg?branch=master)](https://travis-ci.org/dysonance/Temporal.jl)
[![Coverage Status](https://coveralls.io/repos/github/dysonance/Temporal.jl/badge.svg?branch=master)](https://coveralls.io/github/dysonance/Temporal.jl?branch=master)
[![codecov.io](http://codecov.io/github/dysonance/Temporal.jl/coverage.svg?branch=master)](http://codecov.io/github/dysonance/Temporal.jl?branch=master)

[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://dysonance.github.io/Temporal.jl/latest)

# Temporal
This package provides a flexible & efficient time series class, `TS`, for the [Julia](http://julialang.org/) programming language. While still early in development, the overarching goal is for the class to be able to slice & dice data with the rapid prototyping speed of [R](https://www.r-project.org/)'s [`xts`](https://github.com/joshuaulrich/xts) and [Python](https://www.python.org/)'s [`pandas`](http://pandas.pydata.org/) packages, while retaining the performance one expects from Julia.

[See the documentation](http://dysonance.github.io/Temporal.jl/latest/) for a more in-depth look at the package and some of the pain points it may solve when doing technical research with time series data.

Below is a brief teaser with a minimal use case illustrating a small subset of features. This example also makes use of the [Indicators.jl](https://github.com/dysonance/Indicators.jl) package, which provides a series of financial market technical analysis indicators with wrappers for the `Temporal.TS` type. Visualization is offered through the [Plots.jl](http://docs.juliaplots.org/latest/) package, which Temporal leverages through [RecipesBase.jl](https://github.com/JuliaPlots/RecipesBase.jl).

```julia
using Temporal, Plots, Indicators

crude = quandl("CHRIS/CME_CL1")
gasoline = quandl("CHRIS/CME_RB1")

prices = [crude["2012/2019", :Settle] gasoline["2012/2019", :Settle]]
prices.fields = [:Crude, :Gasoline]
prices = dropnan(prices)
daily_returns = diff(log(prices))
cumulative_returns = cumprod(1 + daily_returns)

spread = cumulative_returns[:,1] - cumulative_returns[:,2]
spread = [spread sma(spread, n=200)]
spread.fields = Symbol.(["Spread", "SMA (200)"])

gr()
ℓ = @layout[ a{0.7h}; b{0.3h} ]
plot(cumulative_returns, c=[:black :purple], layout=ℓ, subplot=1)
plot!(spread, c=[:blue :orange], layout=ℓ, subplot=2)
```

![alt text](https://raw.githubusercontent.com/dysonance/Temporal.jl/master/examples/crack_spread.png)
