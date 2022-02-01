using Pkg
Pkg.activate(".")

using Negotiations


params = parameter_set_from_config("test/test-config.yaml")
include("test/create-db.jl")
db = load_database("test.sqlite")

