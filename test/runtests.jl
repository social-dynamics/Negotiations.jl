using Negotiations
using YAML
using Test
using DataFrames
using SQLite


@testset "parameter_set_from_config_test" begin

    if "test.sqlite" in readdir()
        Base.Filesystem.rm("test.sqlite")
    end
    include("create-db.jl")
    test_params = parameter_set_from_config("test-config.yaml")

    # Parameter set
    @test :group_size in propertynames(test_params)
    @test :parliament in propertynames(test_params)
    @test :parliament_size in propertynames(test_params)
    @test :parliament_majority in propertynames(test_params)
    @test :required_consensus in propertynames(test_params)
    @test :parties in propertynames(test_params)
    @test test_params.parliament_size == 157

    Base.Filesystem.rm("test.sqlite")

end  # parameter_set_from_config_test


@testset "load_database_test" begin

    if "test.sqlite" in readdir()
        Base.Filesystem.rm("test.sqlite")
    end
    if "test-faulty.sqlite" in readdir()
        Base.Filesystem.rm("test-faulty.sqlite")
    end
    include("create-db.jl")
    include("create-db-faulty.jl")
    test_db = load_database("test.sqlite")

    @test Negotiations.conforms_to_schema(test_db)
    @test_throws AssertionError load_database("test-faulty.sqlite")

    Base.Filesystem.rm("test.sqlite")
    Base.Filesystem.rm("test-faulty.sqlite")

end  # load_database_test


@testset "opinions_view_test" begin

    if "test.sqlite" in readdir()
        Base.Filesystem.rm("test.sqlite")
    end
    include("create-db.jl")
    test_params = parameter_set_from_config("test-config.yaml")
    test_db = load_database("test.sqlite")
    opinions = opinions_view(test_db)

    @test names(opinions) == ["party_id", "statement_id", "position"]
    @test typeof(opinions) <: AbstractDataFrame
    @test unique(opinions.party_id) == [1, 2, 3]
    @test unique(opinions.statement_id) == [1, 2, 3]
    @test Set(opinions.position) <= Set([-1, 0, 1])

    Base.Filesystem.rm("test.sqlite")

end  # opinions_view_test


@testset "setup_model_test" begin

    if "test.sqlite" in readdir()
        Base.Filesystem.rm("test.sqlite")
    end
    include("create-db.jl")
    test_params = parameter_set_from_config("test-config.yaml")
    test_db = load_database("test.sqlite")

    test_model = setup_model(test_params, test_db)
    test_agents = Negotiations.create_agents(test_params, test_db)

    @test test_model.parameter_set == test_params
    @test length(test_model.agents) == 20
    @test length(Set([a.party for a in test_model.agents])) == 2
    @test length(test_agents) == 20

end  # setup_model_test


@testset "meeting_test" begin

    if "test.sqlite" in readdir()
        Base.Filesystem.rm("test.sqlite")
    end
    include("create-db.jl")
    test_params = parameter_set_from_config("test-config.yaml")
    test_db = load_database("test.sqlite")
    test_model = setup_model(test_params, test_db)
    test_meeting = Negotiations.Meeting(test_model, ["P1", "P2"])

    @test (
        sum([a.party == "P3" for a in test_meeting.participants])
        == 0
    )
    @test length(test_meeting.participants) == 20

end  # meeting_test


@testset "simulation_test" begin

    if "test.sqlite" in readdir()
        Base.Filesystem.rm("test.sqlite")
    end
    include("create-db.jl")
    test_params = parameter_set_from_config("test-config.yaml")
    test_db = load_database("test.sqlite")
    test_model = setup_model(test_params, test_db)

    # @test simulate(test_model, 1, test_db)
    # TODO: create tests for simulation
    @test true

end  # simulation_test
