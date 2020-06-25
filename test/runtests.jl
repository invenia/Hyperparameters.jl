using Hyperparameters

using FilePathsBase
using JSON
using Memento
using Memento.TestUtils

using Test

const LOGGER = getlogger()

@testset "Hyperparameters.jl" begin
    include("hyperparameters.jl")
end
