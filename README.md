# Hyperparameters

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://invenia.github.io/Hyperparameters.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://invenia.github.io/Hyperparameters.jl/dev)
[![CI](https://github.com/Invenia/Hyperparameters.jl/workflows/CI/badge.svg)](https://github.com/Invenia/Hyperparameters.jl/actions?query=workflow%3ACI)
[![Codecov](https://codecov.io/gh/invenia/Hyperparameters.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/invenia/Hyperparameters.jl)

A minimal utility for working with [AWS Sagemaker](https://aws.amazon.com/sagemaker/) hyperparameters.
More broadly for dealing with environment variables.
Two key functions:
 - `hyperparam` reads the enviroment variable
 - `


For purposes of this example we have the following enviroment variables set:
```julia
ENV["SM_HP_FOO"] = "1"; ENV["SM_HP_BAR"] = "2"; ENV["SM_HP_BAZ"] = "three"; ENV["SM_HP_QUX"] = "-3.14";
```
Sagemaker prefixes the environment variables it automatically defines for hyperparameters with `SM_HP_`.


We can access an enviroment variable by name using `hyperparam`:
