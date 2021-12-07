# Party Negotiations

This is a model of the German coalition negotiations to form a government.


## How to use

```{julia}
include("rewrite.jl")

params, opinions = read_config("config.yaml")
model = setup_model(params, opinions, [["SPD", "GRUENE"], ["SPD", "FDP"]])

# To run a single simulation
single_run_data = simulate(model)

# To sample from the model (i.e., run multiple replicates on the same parameter set)
multiple_run_data = sample(model, 5)
```
