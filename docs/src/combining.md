```@index
```

# Joins

## Outer Joins

One can perform a full outer join on the time `index`es of two `TS` objects $x$ and $y$ in the following ways:
- `merge(x, y)`
- `ojoin(x, y)`
- `[x y]`
- `hcat(x, y)`

Where there are dates in the `index` of one that do not exist in the other, values will be filled with `NaN` objects. As the `missing` functionality matures in Julia's base syntax, it will eventually replace `NaN` in this context, since unfortunately `NaN` is only applicable for `Float64` element types.

```@repl
using Temporal, Dates  # hide
x = TS(rand(252))
y = TS(rand(252), x.index .- Month(6))
[x y]
```

## Inner Joins

You can do inner joins on `TS` objects using the `ijoin` function, which will remove any observations corresponding to time steps where at least one of the joined objects is missing a row. This will basically keep only the rows where the time `index` of the LHS and the RHS intersect.

```@repl
using Temporal, Dates  # hide
x = TS(rand(252))
y = TS(rand(252), x.index .- Month(6))
ijoin(x, y)
```

## Left/Right Joins

Left and right joins are performed similarly to inner joins and the typical SQL join queries using the objects' `index` fields as the joining key.

- _Left Join_: keep all observations of the LHS of the join, fill the RHS with NaN's where missing the corresponding time `index`
- _Right Join_: keep all observations of the RHS of the join, fill the LHS with NaN's where missing the corresponding time `index`

```@repl
using Temporal, Dates  # hide
x = TS(rand(252))
y = TS(rand(252), x.index .- Month(6))
ljoin(x, y)
rjoin(x, y)
```
