using Pkg
Pkg.activate(".")

include("src/Negotiations.jl")

params = Negotiations.read_config("config.yaml")
model = Negotiations.setup_model(params, [["SPD", "GRUENE"], ["SPD", "FDP"]])

# To run a single simulation
single_run_data = Negotiations.simulate(model)

# To sample from the model (i.e., run multiple replicates on the same parameter set)
multiple_run_data = Negotiations.sample(model, 5)
