using Negotiations
using YAML
using Test


# read test model specifications to use throughout testing
test_params = read_config("test-config.yaml")


@testset "read_config_test" begin
    @test :group_size in propertynames(test_params)
    @test :parliament in propertynames(test_params)
    @test :parliament_size in propertynames(test_params)
    @test :parliament_majority in propertynames(test_params)
    @test :required_consensus in propertynames(test_params)
    @test :parties in propertynames(test_params)
    @test :opinions in propertynames(test_params)
    @test test_params.parliament_size == 157
end  # read_config_test


@testset "extract_opinions_test" begin
    config_dict = YAML.load_file("test-config.yaml")
    opinions = Negotiations.extract_opinions(config_dict)
    @test filter(x -> !(x in [-1, 0, 1]), opinions[:TEST_PARTY_1]) == []
    @test typeof(opinions) <: Dict{Any, Any}
    @test !(:TEST_PARTY_3 in keys(opinions))
end  # extract_opinions_test


@testset "calculate_parliament_size_test" begin
    config_dict = YAML.load_file("test-config.yaml")
    parliament_size = Negotiations.calculate_parliament_size(config_dict)
    @test parliament_size == 157
end


@testset "setup_model_test" begin
    test_model = setup_model(test_params, [["TEST_PARTY_1", "TEST_PARTY_2"]])
    @test test_model.parameter_set == test_params
    @test length(test_model.agents) == 20
end




