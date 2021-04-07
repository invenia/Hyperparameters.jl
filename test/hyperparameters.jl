@testset "hyperparameters" begin
    empty!(HYPERPARAMETERS)

    withenv("SM_HP_HPA" => "1", "SM_HP_HPB" => "2", "OTHER_HPC" => "3.0", "OTHER_HPD" => "hi") do
        @test HYPERPARAMETERS == Dict()

        hp = hyperparam(Float64, :hpa)
        @test hp == 1.0
        @test hp isa Float64
        @test HYPERPARAMETERS == Dict(:hpa => 1.0)
        @test HYPERPARAMETERS[:hpa] isa Float64

        hp = hyperparam(String, :hpb)
        @test hp == "2"
        @test HYPERPARAMETERS == Dict(:hpa => 1.0, :hpb => "2")

        # Log if type changes
        @test_log LOGGER "notice" "type of HYPERPARAMETERS[:hpa]" hyperparam(Int, :hpa)
        # No log if value is unchanged
        @test_nolog LOGGER "notice" "HYPERPARAMETERS[:hpa]" hyperparam(Int, :hpa)
        hp = HYPERPARAMETERS[:hpa]
        @test hp == 1
        @test hp isa Int
        @test HYPERPARAMETERS == Dict(:hpa => 1, :hpb => "2")

        hp = hyperparam(String, :hpc; prefix="OTHER_")
        @test hp == "3.0"
        @test HYPERPARAMETERS == Dict(:hpa => 1, :hpb => "2", :hpc => "3.0")
        # Log if old value != new value
        @test_log LOGGER "notice" "Overwriting HYPERPARAMETERS[:hpc]" hyperparam(Float64, :hpc; prefix="OTHER_")
        @test HYPERPARAMETERS == Dict(:hpa => 1, :hpb => "2", :hpc => 3.0)

        # No Key
        @test_throws KeyError hyperparam(:hpa; prefix="OTHER_")
        # Parse error
        @test_throws ArgumentError hyperparam(Float64, :hpd; prefix="OTHER_")
        @test HYPERPARAMETERS == Dict(:hpa => 1, :hpb => "2", :hpc => 3)

        empty!(HYPERPARAMETERS)
        @test HYPERPARAMETERS == Dict()

        hp = hyperparams(:hpc; prefix="OTHER_")
        @test hp == (hpc=3,)
        @test hp.hpc isa Float64
        @test HYPERPARAMETERS == Dict(:hpc => 3.0)
        @test HYPERPARAMETERS[:hpc] isa Float64

        @test_throws ArgumentError hyperparams(:hpa, :hpb; types=[Int, String, String])
        @test HYPERPARAMETERS == Dict(:hpc => 3)

        hp = hyperparams(:hpa, :hpb; types=[Int, String])
        @test hp == (hpa=1, hpb="2")
        @test hp.hpa isa Int
        @test HYPERPARAMETERS == Dict(:hpa => 1, :hpb => "2", :hpc => 3)
        @test HYPERPARAMETERS[:hpa] isa Int

        save_hyperparam(:hpd, 4, prefix="OTHER_")
        @test HYPERPARAMETERS[:hpd] isa Int
        @test HYPERPARAMETERS[:hpd] == 4
        @test ENV["OTHER_HPD"] == "4"
    end

    @testset "report_hyperparameters" begin
        # Ensure hyperparameters are what we expect
        empty!(HYPERPARAMETERS)

        withenv("SM_HP_HPA" => "1", "SM_HP_HPB" => "2", "SM_HP_HPC" => "3") do
            # we use hpa and hpb, but we want hpc to just be scoped from environment
            hyperparam(Float64, :hpa)
            hyperparam(String, :hpb)
            # It will have to guess the type of hpc

            mktmpdir() do dir
                @test_log LOGGER "info" "hyperparameters: hpb=2" report_hyperparameters(dir)

                contents = read(joinpath(dir, "hyperparameters.json"), String)
                @test occursin("\"hpa\": 1.0", contents)
                @test occursin("\"hpb\": \"2\"", contents)
                @test occursin("\"hpc\": 3", contents)
            end
        end
    end

    @testset "_parse_hyper: guessing type correctly" begin
        _parse_hyper = Hyperparameters._parse_hyper

        @test _parse_hyper("true") isa Bool
        @test _parse_hyper("true") == true
        @test _parse_hyper("false") isa Bool
        @test _parse_hyper("false") == false

        @test _parse_hyper("1") isa Integer
        @test _parse_hyper("1") == 1
        @test _parse_hyper("-1") isa Integer
        @test _parse_hyper("-1") == -1

        @test _parse_hyper("2.0") isa AbstractFloat
        @test _parse_hyper("2.0") == 2.0
        @test _parse_hyper("-2.0") isa AbstractFloat
        @test _parse_hyper("-2.0") == -2.0

        @test _parse_hyper("three") isa AbstractString
        @test _parse_hyper("three") == "three"

        # if not matching julia lowercase convention get strings:
        @test _parse_hyper("TRUE") isa AbstractString
        @test _parse_hyper("True") isa AbstractString
    end
end
