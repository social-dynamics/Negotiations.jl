using Pkg
Pkg.activate(".")

using Negotiations

params = parameter_set_from_config("test/test-config.yaml")
include("test/create-db.jl")
db = load_database("test.sqlite")
model = setup_model(params, db)
rule = BoundedConfidence(bc = 2.0, inertia = 10.0)
simulate(model, rule, 2, db, batchname = "test")
