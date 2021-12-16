using Pkg
Pkg.activate(".")

include("src/Negotiations.jl")

using Combinatorics
using Random


function snap_model(model_results, i)
    model_results[!, :model] .= i
    return model_results
end

params = Negotiations.read_config("config.yaml")

all_combinations = collect(combinations(params.parties, 2))
sequences = [deepcopy(shuffle(all_combinations)) for i in 1:3]

models = [
    Negotiations.setup_model(
        params,
        comb
    ) for comb in sequences
]

# To run a single simulation
single_run_data = Negotiations.simulate.(models)

# To sample from the model (i.e., run multiple replicates on the same parameter set)
multiple_run_data = reduce(vcat, [snap_model(m, i) for (i, m) in enumerate(Negotiations.sample.(models, 5))])


# using Arrow

# Arrow.write("../data-exploration/data.arrow", multiple_run_data)

