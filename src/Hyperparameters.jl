module Hyperparameters

using FilePathsBase: AbstractPath, /
using JSON
using Memento

export HYPERPARAMETERS, hyperparam, hyperparams, report_hyperparameters

const MODULE = @__MODULE__
const LOGGER = getlogger(MODULE)

"""
    HYPERPARAMETERS::Dict{Symbol, Any}

Collection of all the hyperparameters, and their values accessed during this run.
"""
const HYPERPARAMETERS = Dict{Symbol, Any}()
const SAGEMAKER_PREFIX = "SM_HP_"

# Grabs hyperparameter from environment variables
_get_hyperparam(name::Symbol, prefix::AbstractString)= ENV[uppercase(string(prefix, name))]

# Records a hyper-parameter into global HYPERPARAMETERS dict for later reporting
# Logs if a hyperparameter is set twice to two difference values
function _set_hyperparam(name::Symbol, value)
    if haskey(HYPERPARAMETERS, name)
        orig = HYPERPARAMETERS[name]
        if orig != value
            notice(LOGGER, "Overwriting HYPERPARAMETERS[:$name] from $(repr(orig)) to $(repr(value)).")
        elseif typeof(orig) != typeof(value)
            notice(
                LOGGER,
                "Changing type of HYPERPARAMETERS[:$name] from $(typeof(orig)) to $(typeof(value))."
            )
        end
    end
    HYPERPARAMETERS[name] = value
end

"""
    hyperparam([T::Type=Float64,] name; prefix="$SAGEMAKER_PREFIX"))

Load the hyperparameter with the given `name` from the enviroment variable
named with the name in uppercase, and prefixed with `prefix`
parsing it as type `T` (default: `Float64`).

Also stores the hyperparameter and its value in the global `HYPERPARAMETERS` dictionary.
This function is generally expected to be used with SageMaker, and supplies the default prefix for it.
```jldoctest
using Hyperparameters
ENV["HP_POWER_LEVEL"] = "9001"
hyperparam(:power_level; prefix="HP_")

# output
9001.0
```
"""
function hyperparam(name::Symbol; prefix::AbstractString=SAGEMAKER_PREFIX)
    return hyperparam(Float64, name; prefix=prefix)
end
function hyperparam(T::Type, name::Symbol; prefix::AbstractString=SAGEMAKER_PREFIX)
    value = parse(T, _get_hyperparam(name, prefix))
    _set_hyperparam(name, value)
    return value
end

function hyperparam(::Type{String}, name::Symbol; prefix::AbstractString=SAGEMAKER_PREFIX)
    value = _get_hyperparam(name, prefix)
    _set_hyperparam(name, value)
    return value
end

"""
    hyperparams(names...; prefix="$SAGEMAKER_PREFIX")

As per [`hyperparam`](@ref), but taking multiple names and returning a `NamedTuple`.
```jldoctest
using Hyperparameters
ENV["$(SAGEMAKER_PREFIX)A"] = "5"
ENV["$(SAGEMAKER_PREFIX)B"] = "1.22"
hyperparams(:a, :b, types=[Int, Float64])

# output
(a = 5, b = 1.22)
```
Also stores the hyperparameters and their values in the global `HYPERPARAMETERS`
dictionary.
"""
function hyperparams(
    names::Vararg{Symbol};
    prefix::AbstractString=SAGEMAKER_PREFIX,
    types::Union{Nothing, AbstractVector{<:Type}}=nothing
)
    parameters = if types === nothing
        (name => hyperparam(name; prefix=prefix) for name in names)
    else
        length(names) == length(types) || throw(ArgumentError(
            "Number of `names` and `types` must be equal $(length(names)) != $(length(types))"
        ))
        (name => hyperparam(type, name; prefix=prefix) for (name, type) in zip(names, types))
    end

    return (; parameters...)
end

"""
    report_hyperparameters(save_dir::AbstractPath)

Saves the cached `HYPERPARAMETERS` to a JSON file named "hyperparameters.json" in the `save_dir`
and prints each key-value pair to the logger.

The regex to extract the components is: `hyperparameters: (?<key>)=(?<value>)`.
"""
function report_hyperparameters(save_dir::AbstractPath)
    for (key, value) in pairs(HYPERPARAMETERS)
        info(LOGGER, "hyperparameters: $key=$value")
    end

    file = save_dir / "hyperparameters.json"
    info(LOGGER, "Report: saving at $file")

    open(file, "w") do fh
        JSON.print(fh, HYPERPARAMETERS, 4)  # 4 space indenting
    end

    return file
end

end # module
