# Hyperparameters

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://invenia.github.io/Hyperparameters.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://invenia.github.io/Hyperparameters.jl/dev)
[![CI](https://github.com/Invenia/Hyperparameters.jl/workflows/CI/badge.svg)](https://github.com/Invenia/Hyperparameters.jl/actions?query=workflow%3ACI)
[![Codecov](https://codecov.io/gh/invenia/Hyperparameters.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/invenia/Hyperparameters.jl)

A minimal utility for working with [AWS Sagemaker](https://aws.amazon.com/sagemaker/) hyperparameters.
More broadly for dealing with environment variables.
Two key functions:
 - `hyperparam` reads the enviroment variable
 - `report_hyperparameters` writes them to a JSON file, and logs them.


For purposes of this example we have the following environment variables set:
```julia
ENV["SM_HP_FOO"] = "1";
ENV["SM_HP_BAR"] = "2";
ENV["SM_HP_BAZ"] = "three";
ENV["SM_HP_QUX"] = "-3.14";
```
Sagemaker prefixes the environment variables it automatically defines for hyperparameters with `SM_HP_`.

### Accessing Hyper-parameters
We can access an enviroment variable by name using `hyperparam`:
```julia
julia> hyperparam(:foo)
1
```

We can tell it the type by passing that as the first argument:
```julia
julia> hyperparam(Float64, :bar)
2.0
```

If we don't it defaults to trying in order: `Bool`, `Int`, `Float64` and finally falling back to assuming it is a `String`:
```julia
julia> hyperparam(:baz)
"three"
```

### Generating a report
`report_hyperparameters(directory)` is used to output all the hyperparameters to the logs,
and write a file called `hyperparameters.json` into the directory.

```julia
julia> using FilePathsBase

julia> report_hyperparameters(p".")
[info | Hyperparameters]: hyperparameters: baz=three
[info | Hyperparameters]: hyperparameters: bar=2.0
[info | Hyperparameters]: hyperparameters: qux=-3.14
[info | Hyperparameters]: hyperparameters: foo=1
[info | Hyperparameters]: Report: saving at ./hyperparameters.json
p"./hyperparameters.json"
```
The JSON file looks like:
```json
{
    "baz": "three",
    "bar": 2.0,
    "qux": -3.14,
    "foo": 1
}
```

Notice two key things:
1. Even though `qux` was never accessed during out code, it is still saved as the enviroment variable existed with the right prefix. It's type was found with the same mechanism used if the type is not provided to `hyperparam`. Which determined it was a `Float64` (and not a `String`).
2. When we accessed `bar` passing in the type, that type was remembered, so even though the enviroment variables just contained `2`, the report correctly read `2.0`

