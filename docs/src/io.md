# Data Readers

## Flat Files

```@repl
using Temporal, Pkg
filepath = "Pkg.Pkg2.dir("Temporal")/data/Corn.csv"
X = tsread(filepath)
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
