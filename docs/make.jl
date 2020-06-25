using Documenter, Hyperparameters

makedocs(;
    modules=[Hyperparameters],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/invenia/Hyperparameters.jl/blob/{commit}{path}#L{line}",
    sitename="Hyperparameters.jl",
    authors="Invenia Technical Computing Corporation",
    assets=[
        "assets/invenia.css",
        "assets/logo.png",
    ],
)

deploydocs(;
    repo="github.com/invenia/Hyperparameters.jl",
)
