[![Build Status](https://travis-ci.org/dysonance/Temporal.jl.svg?branch=master)](https://travis-ci.org/dysonance/Temporal.jl)
[![Coverage Status](https://coveralls.io/repos/github/dysonance/Temporal.jl/badge.svg?branch=master)](https://coveralls.io/github/dysonance/Temporal.jl?branch=master)
[![codecov.io](http://codecov.io/github/dysonance/Temporal.jl/coverage.svg?branch=master)](http://codecov.io/github/dysonance/Temporal.jl?branch=master)

[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://dysonance.github.io/Temporal.jl/latest)

# Temporal
This package provides a flexible & efficient time series class, `TS`, for the [Julia](http://julialang.org/) programming language. While still early in development, the overarching goal is for the class to be able to slice & dice data with the rapid prototyping speed of [R](https://www.r-project.org/)'s [`xts`](https://github.com/joshuaulrich/xts) and [Python](https://www.python.org/)'s [`pandas`](http://pandas.pydata.org/) packages, while retaining the performance one expects from Julia.

# Installation
`Temporal` can be easily installed using Julia's built-in package manager.

```julia
using Pkg
Pkg.add("Temporal")
using Temporal
```
