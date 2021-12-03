using YAML
include("src/Negotiations.jl")

config = Negotiations.Config("config.yaml")

# Parliament specifications
ALL_SEATS = config.all_seats
MAJORITY_REQUIREMENT = config.majority_requirement
seats = config.seat_distribution

# Test
negotiators = Negotiations.setup_negotiators(10, config)
combs = Negotiations.get_party_combinations(config.party_names, 2)
res = Negotiations.meta_run!(negotiators, combs)
