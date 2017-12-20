# Joins

## Outer Joins

One can perform a full outer join on the time `index`es of two `TS` objects $x$ and $y$ in the following ways:
- `merge(x, y)`
- `ojoin(x, y)`
- `[x y]`

Where there are dates in the `index` of one that do not exist in the other, values will be filled with `NaN` objects. As the `missing` functionality matures in Julia's base syntax, it will eventually replace `NaN` in this context, since unfortunately `NaN` is only applicable for `Float64` element types.

## Inner Joins

## Left Joins

## Right Joins
