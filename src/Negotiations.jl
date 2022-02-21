module Negotiations

# Dependencies
using YAML
using CSV
using DataFrames
using StatsBase
using Random
using Combinatorics
using SQLite
using ProgressMeter
using Chain
using Distributed

# Exports
export Agent
export ParameterSet
export Model
export Meeting
export initialize_db
export parameter_set_from_config
export load_database
export opinions_view
export setup_model
export simulate
export Rule
export BoundedConfidence
export ContinuousHomophily
export RealPolitics

# Source scripts
include("db_operations.jl")
include("data_views.jl")
include("config.jl")
include("model.jl")
include("rules.jl")
include("simulation.jl")
# include("convergence.jl")

end  # module
