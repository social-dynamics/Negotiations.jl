using Pkg
Pkg.activate(".")

using Negotiations

params, db = read_config("config.yaml")
a = Negotiations.create_agents(params, db)
print(a)
