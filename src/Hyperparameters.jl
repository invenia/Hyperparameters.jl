module Hyperparameters

using FilePathsBase: AbstractPath, /
using JSON
using Memento

export HYPERPARAMETERS, hyperparam, hyperparams, report_hyperparameters, save_hyperparam

const MODULE = @__MODULE__
const LOGGER = getlogger(MODULE)

"""
    HYPERPARAMETERS::Dict{Symbol, Any}

Collection of all the hyperparameters, and their values accessed during this run.
"""
const HYPERPARAMETERS = Dict{Symbol, Any}()
const SAGEMAKER_PREFIX = "SM_HP_"


_name_to_envvar(prefix, name) = uppercase(string(prefix, name))
function _envvar_to_name(prefix, name)
    startswith(name, prefix) || throw(DomainError(name, "Should have prefix; $prefix"))
    return Symbol(lowercase(SubString(name, length(prefix) + 1)))
end

# Grabs hyperparameter from environment variables
_get_hyperparam(name::Symbol, prefix::AbstractString)= ENV[_name_to_envvar(prefix, name)]

# Records a hyperparameter into global HYPERPARAMETERS dict for later reporting
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
    hyperparam([T::Type,] name; prefix="$SAGEMAKER_PREFIX"))

Load the hyperparameter with the given `name` from the environment variable
named with the name in uppercase, and prefixed with `prefix`.
If the type `T` is passed then it will be parsed as that type,
otherwise it will take a guess at the type chosing the first that passes successfully
from `Bool`, `Int`, then `Float` then `String`

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
    return hyperparam(nothing, name; prefix=prefix)
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

function hyperparam(::Nothing, name::Symbol; prefix::AbstractString=SAGEMAKER_PREFIX)
    # this one is adaptive to try and work out the type from the string.
    value = _parse_hyper(_get_hyperparam(name, prefix))
    _set_hyperparam(name, value)
    return value
end

"""
    _parse_hyper(value_string)

Guesses the type of the `value_string` and parses as that.
"""
function _parse_hyper(value_string)
    return something(
        _strict_tryparse_bool(value_string),
        tryparse(Int, value_string),
        tryparse(Float64, value_string),
        value_string,
    )
end

# tryparse(Bool, "1") == true so can't use that. This is stricter
_strict_tryparse_bool(x) = x == "true" ? true : x == "false" ? false : nothing

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
    save_hyperparam(name::Symbol, value, prefix::AbstractString="")

Save value to the enviroment variables and the global `HYPERPARAMETERS` dictionary.
"""
function save_hyperparam(name::Symbol, value; prefix::AbstractString="")
    ENV[_name_to_envvar(prefix, name)] = string(value)
    _set_hyperparam(name, value)
end

"""
    report_hyperparameters(save_dir::AbstractPath; prefix="$SAGEMAKER_PREFIX")

Saves all hyperparameters to a JSON file named "hyperparameters.json" in the `save_dir`
and prints each key-value pair to the logger.

The hyperparameters are taken from the cached `HYPERPARAMETERS` dictionary of all that were
used, combined with any enviroment variables matching the prefix.
Where things occur in both, the cached dictionary takes precedence.
Hyperparameters read from enviroment variables are all recorded as strings.
(You can overwrite this by using them via `hyperparam(type, name)` before the report)

The regex to extract the components is: `hyperparameters: (?<key>)=(?<value>)`.
"""
function report_hyperparameters(save_dir::AbstractPath; prefix=SAGEMAKER_PREFIX)
    env_hypers = Dict(
        _envvar_to_name(prefix, k) => _parse_hyper(v)
        for (k, v) in ENV if startswith(k, prefix)
    )
    all_hypers = merge(env_hypers, HYPERPARAMETERS)
    for (key, value) in all_hypers
        info(LOGGER, "hyperparameters: $key=$value")
    end

    file = save_dir / "hyperparameters.json"
    info(LOGGER, "Report: saving at $file")

    open(file, "w") do fh
        JSON.print(fh, all_hypers, 4)  # 4 space indenting
    end

    return file
end

end # module
