@testset "hyperparameters" begin
    empty!(HYPERPARAMETERS)

    withenv("SM_HP_HPA" => "1", "SM_HP_HPB" => "2", "OTHER_HPC" => "3", "OTHER_HPD" => "hi") do
        @test HYPERPARAMETERS == Dict()

        hp = hyperparam(:hpa)
        @test hp == 1
        @test hp isa Float64
        @test HYPERPARAMETERS == Dict(:hpa => 1)
        @test HYPERPARAMETERS[:hpa] isa Float64

        hp = hyperparam(String, :hpb)
        @test hp == "2"
        @test HYPERPARAMETERS == Dict(:hpa => 1, :hpb => "2")

        # Log if type changes
        @test_log JOBS_LOGGER "notice" "type of HYPERPARAMETERS[:hpa]" hyperparam(Int, :hpa)
        # No log if value is unchanged
        @test_nolog JOBS_LOGGER "notice" "HYPERPARAMETERS[:hpa]" hyperparam(Int, :hpa)
        hp = HYPERPARAMETERS[:hpa]
        @test hp == 1
        @test hp isa Int
        @test HYPERPARAMETERS == Dict(:hpa => 1, :hpb => "2")

        hp = hyperparam(String, :hpc, "OTHER_")
        @test hp == "3"
        @test HYPERPARAMETERS == Dict(:hpa => 1, :hpb => "2", :hpc => "3")
        # Log if old value != new value
        @test_log JOBS_LOGGER "notice" "Overwriting HYPERPARAMETERS[:hpc]" hyperparam(Int, :hpc, "OTHER_")
        @test HYPERPARAMETERS == Dict(:hpa => 1, :hpb => "2", :hpc => 3)

        # No Key
        @test_throws KeyError hyperparam(:hpa, "OTHER_")
        # Parse error
        @test_throws ArgumentError hyperparam(:hpd, "OTHER_")
        @test HYPERPARAMETERS == Dict(:hpa => 1, :hpb => "2", :hpc => 3)

        empty!(HYPERPARAMETERS)
        @test HYPERPARAMETERS == Dict()

        hp = hyperparams(:hpc; prefix="OTHER_")
        @test hp == (hpc=3,)
        @test hp.hpc isa Float64
        @test HYPERPARAMETERS == Dict(:hpc => 3)
        @test HYPERPARAMETERS[:hpc] isa Float64

        @test_throws ArgumentError hyperparams(:hpa, :hpb; types=[Int, String, String])
        @test HYPERPARAMETERS == Dict(:hpc => 3)

        hp = hyperparams(:hpa, :hpb; types=[Int, String])
        @test hp == (hpa=1, hpb="2")
        @test hp.hpa isa Int
        @test HYPERPARAMETERS == Dict(:hpa => 1, :hpb => "2", :hpc => 3)
        @test HYPERPARAMETERS[:hpa] isa Int
    end

    @testset "report_hyperparameters" begin
        # Ensure hyperparameters are what we expect
        empty!(HYPERPARAMETERS)
        push!(HYPERPARAMETERS, :hpa => 1.0, :hpb => "2", :hpc => 3)

        mktmpdir() do dir
            @test_log JOBS_LOGGER "info" "hyperparameters: hpb=2" EISJobs.report_hyperparameters(dir)
            contents = read(dir / "hyperparameters.json", String)
            @test occursin("\"hpb\": \"2\"", contents)
            @test occursin("\"hpa\": 1.0", contents)
            @test occursin("\"hpc\": 3", contents)
        end
    end
end
