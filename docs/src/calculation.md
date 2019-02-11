# Computations

## Operators

```@autodocs
Modules = [Temporal]
Pages = ["operations.jl"]
```

#### Scalars

```@repl
using Temporal
X = TS(rand(100, 4))
X + 1
X - 1
X * 2
X / 2
X % 2
X ^ 2
```

### Time Series

```@repl
using Temporal
X = TS(rand(100, 4))
Y = TS(randn(100, 4))
X + Y
X - Y
X * Y
X / Y
X % Y
X ^ Y
```

## Statistics

```@repl
using Temporal
X = TS(randn(100, 4))
mean(X)
sum(X)
prod(X)
cumsum(X)
cumprod(X)
sign(X)
log(X)
minimum(X)
cummin(X)
maximum(X)
cummax(X)
```

