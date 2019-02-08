# Data Readers

## Flat Files

```@repl
using Temporal
X = TS(randn(252, 4))
filepath = "tmp.csv"
tswrite(X, filepath)
Y = tsread(filepath)
X == Y
```

## Yahoo

```@repl
using Temporal
X = yahoo("FB")
```

## Quandl

```@repl
using Temporal
X = quandl("CHRIS/CME_CL1", from="2010-01-01")
```
