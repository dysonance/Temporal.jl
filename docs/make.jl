using Documenter, Temporal

makedocs(modules=[Temporal],
         #doctest=false,
         #clean=true,
         #format=:html,
         authors="Jacob Amos",
         pages=Any["Home" => "index.md",
                   "TS Object" => "ts.md",
                   "Operations" => "operations.md",
                   "Data Manipulation" => Any["indexing.md",
                                              "combining.md",
                                              "aggregation.md"]])

