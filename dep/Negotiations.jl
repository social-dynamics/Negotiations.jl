module Negotiations

using Agents
using Graphs
using StatsBase
using Random
using CSV
using DataFrames
using Combinatorics
using YAML

export Negotiator
export NegotiationModel
export Config
export setup_negotiators
export get_party_combinations
export meta_run!

include("config.jl")
include("types.jl")
include("simulation.jl")

end  # end module




