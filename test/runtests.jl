using Negotiations
using YAML
using Test
using DataFrames
using SQLite

include("create-db.jl")

@testset "read_config_test" begin

    test_params, test_db = read_config("test-config.yaml")

    # Parameter set
    @test :group_size in propertynames(test_params)
    @test :parliament in propertynames(test_params)
    @test :parliament_size in propertynames(test_params)
    @test :parliament_majority in propertynames(test_params)
    @test :required_consensus in propertynames(test_params)
    @test :parties in propertynames(test_params)
    @test :opinions in propertynames(test_params)
    @test test_params.parliament_size == 157

    # Database
    @test SQLite.tables(test_db).name == ["party", "statement", "opinion"]

end  # read_config_test


@testset "extract_opinions_test" begin

    test_params, test_db = read_config("test-config.yaml")
    opinions = Negotiations.extract_opinions(test_db)

    @test names(opinions) == ["party_id", "statement_id", "position"]
    @test typeof(opinions) <: AbstractDataFrame
    @test unique(opinions.party_id) == [1, 2, 3]
    @test unique(opinions.statement_id) == [1, 2, 3]
    @test Set(opinions.position) <= Set([-1, 0, 1])

end  # extract_opinions_test


# @testset "calculate_parliament_size_test" begin
#     config_dict = YAML.load_file("test-config.yaml")
#     parliament_size = Negotiations.calculate_parliament_size(config_dict)
#     @test parliament_size == 157
# end  # calculate_parliament_size_test


# @testset "setup_model_test" begin
#     test_params = read_config("test-config.yaml")
#     test_model = setup_model(
#         test_params,
#         [["TEST_PARTY_1", "TEST_PARTY_2"]]
#     )
#     @test test_model.parameter_set == test_params
#     @test length(test_model.agents) == 20
# end  # setup_model_test


# @testset "meeting_test" begin
#     test_params = read_config("test-config.yaml")
#     test_model = setup_model(
#         test_params,
#         [["TEST_PARTY_1", "TEST_PARTY_2"]]
#     )
#     meeting = Negotiations.Meeting(
#         test_model,
#         ["TEST_PARTY_1", "TEST_PARTY_3"]
#     )
#     @test (
#         sum([a.party == "TEST_PARTY_2" for a in meeting.participants])
#         == 0
#     )
# end  # meeting_test


# @testset "similarity_and_assimilate_test" begin
#     sender = Agent(1, "TEST_PARTY_1", [0, -1, 1])
#     receiver = Agent(2, "TEST_PARTY_2", [0, 1, 1])
#     prior_similarity = Negotiations.similarity(sender, receiver)
#     Negotiations.assimilate!(sender, receiver)
#     @test Negotiations.similarity(sender, receiver) >= prior_similarity
# end  # similarity_and_assimilate_test


# @testset "simulation_test" begin
#     test_params = read_config("test-config.yaml")
#     test_model = setup_model(
#         test_params,
#         [
#             ["TEST_PARTY_1", "TEST_PARTY_2"],
#             ["TEST_PARTY_1", "TEST_PARTY_3"]
#         ]
#     )
#     test_model_sample_data_1 = simulate(test_model)
#     test_model_sample_data_5 = sample(test_model, 5)
#     Negotiations.snap_rep(test_model_sample_data_1, 13)
#     @test :rep in propertynames(test_model_sample_data_1)
#     @test (
#         sum(test_model_sample_data_1.rep .== 13)
#         == nrow(test_model_sample_data_1)
#     )
#     @test typeof(test_model_sample_data_5) == DataFrames.DataFrame
#     @test maximum(test_model_sample_data_5.rep) == 5
# end  # negotiations_sample_test


Base.Filesystem.rm("test.sqlite")

