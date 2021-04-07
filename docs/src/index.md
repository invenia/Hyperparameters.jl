# Hyperparameters.jl

Hyperparameters can be retrieved from environment variables using `hyperparam` or `hyperparams`.

The environment variables holding hyperparameters are expected to be denoted with a prefix according to their use.
The primary use case for this is Sagemaker wherein all hyperparameters are prefixed with `SM_HP_`.
The sagemaker default prefix will be used if a prefix is not supplied.

Any retrieved hyperparameters will be stored in the `HYPERPARAMETERS` Dict and can be logged and saved through [`report_hyperparameters`](@ref).
If the values or types of these hyperparameters are changed on subsequent retrievals a notice message will be logged.
Note that hyperparameters are stored without their prefix and will be overwritten by hyperparameters with identical names from different prefixes,
should you retrieve hyperparameters from multiple prefixes.

```@autodocs
Modules = [Hyperparameters]
```
