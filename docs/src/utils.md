# Package Options
There are main package options that can be adjusted to change the way that Temporal behaves.

## Range Delimiter
The `RANGE_DELIMITER` option specifies what value should separate the `String`s when indexing a `TS` object's rows using the `String` indexing syntax.

By default, `RANGE_DELIMITER` is set to '/', and can be changed dynamically using the function `set_range_delimiter_option`.

```@example
using Temporal, Base.Dates;
index = Date("2017-01-01"):Day(1):Date(2017-12-31);
values = cumsum(randn(length(index), 4));
X = TS(values, index)

X["2017-03-15/"]

set_range_delimiter_option("::")

X["2017-03-15::2017-06-15"]

# fails since the RANGE_DELIMITER package option was changed above
X["2017-03-15/"]
```

## Name Sanitization
The `SANITIZE_NAMES` option is a boolean value indicating whether the column names (that is, the object's `fields` member), should be cleaned of whitespace and non-alphanumeric characters before constructing `TS` objects. This can make it easier to deal with names of columns more quickly and easily in some cases.

By default, `SANITIZE_NAMES` is set to `false`, so that generally speaking the raw user input data is used. This option can be changed with the `set_sanitize_names_option` function.

```@example
using Temporal, Base.Dates;
A = tsread(Pkg.dir("Temporal", "data", "XOM.csv"))
set_sanitize_names_option(true)
B = tsread(Pkg.dir("Temporal", "data", "XOM.csv"))
```