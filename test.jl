using Pkg
Pkg.activate(".")

include("rewrite.jl")

params, opinion_data = read_config("config.yaml")
model = setup_model(params, opinion_data, negotiation!, can_form_government, [])
print("Success.")

