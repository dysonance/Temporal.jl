using Documenter, Temporal

makedocs(modules=[Temporal],
         doctest=false,
         clean=true,
         format=Documenter.HTML(),
         authors="Jacob Amos",
         sitename="Temporal",
         pages=["Home" => "index.md",
                "Overview" => "overview.md",
                "Calculations" => ["Methods" => "calculation.md",
                                   "Aggregation" => "aggregation.md"],
                "Data" => ["I/O" => "io.md",
                           "Subsetting" => "indexing.md",
                           "Combining" => "combining.md"]])

deploydocs(deps=Deps.pip("mkdocs", "python-markdown-math"),
           repo="github.com/dysonance/Temporal.jl.git",
           devbranch="master",
           devurl="dev",
           versions=["stable" => "v^", "v#.#", "dev" => "dev"])
