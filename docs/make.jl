using Documenter, Temporal

makedocs(modules=[Temporal],
         doctest=false,
         clean=true,
         format=Documenter.HTML(),
         authors="Jacob Amos",
         sitename="Temporal",
         pages=Any["Home" => "index.md",
                   "TS Object" => "ts.md",
                   "Operations" => "operations.md",
                   "Data Access" => "io.md",
                   "Data Manipulation" => ["indexing.md", "combining.md", "aggregation.md"]])

deploydocs(deps=Deps.pip("mkdocs", "python-markdown-math"),
           repo="github.com/dysonance/Temporal.jl.git",
           devbranch="master",
           devurl="dev",
           versions=["stable" => "v^", "v#.#", "dev" => "dev"])
