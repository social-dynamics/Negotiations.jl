using Agents
using LightGraphs
using StatsBase
using Random
using CSV
using DataFrames

# The agent type
@agent Negotiator{} Agents.GraphAgent begin
    opinions::AbstractArray
end

# Actions that each agent performs in each step
function agent_step!(agent::Negotiator, model::Agents.ABM)
    assimilate!(agent, model)
    return model
end

# Axelrod rule
function assimilate!(agent, model)
    interaction_partner = StatsBase.sample(nearby_ids(agent.pos, model, 1), 1)
    if Random.rand() < 0.5  # TO DO: implement homophily
        dim_to_switch = 1  # TO DO: choose at random
        agent.opinions[1] = 1  # TO DO: implement ordinal Axelrod
    end
    return agent
end

# Run once every step to update model parameters
function model_step!(model::Agents.ABM)
    return model
end

# Populate a model with agents
function populate!(model::Agents.ABM, negotiator_group::AbstractArray)
    negotiator_group = vcat(negotiator_group...)
    for i in 1:nv(model.space.graph)
        add_agent!(negotiator_group[i], i, model)
    end
    return model
end

function negotiation(parties::AbstractArray)
    n_participants = length(parties)
    space = Agents.GraphSpace(LightGraphs.complete_graph(n_participants * GROUPSIZE))
    model = Agents.ABM(Negotiator, space)
    populate!(model, parties)
    adata, mdata = run!(model, agent_step!, model_step!, 100, adata=[:opinions], obtainer=deepcopy)
    return adata
end

# Setup (TO DO: wrap into functions)
GROUPSIZE = 10
space = Agents.GraphSpace(LightGraphs.complete_graph(GROUPSIZE))
model = Agents.ABM(Negotiator, space)

# TO DO: use actual data to initialize agents
data = CSV.read(joinpath("data", "data_wide.csv"), DataFrame)

# Setup negotiator groups
spd = [Negotiator(i, i, zeros(Int, 38)) for i in 1:GROUPSIZE]
cdu = [Negotiator(i, i, zeros(Int, 38)) for i in 11:GROUPSIZE * 2]
gruene = [Negotiator(i, i, zeros(Int, 38)) for i in 21:GROUPSIZE * 3]
fdp = [Negotiator(i, i, zeros(Int, 38)) for i in 31:GROUPSIZE * 4]
afd = [Negotiator(i, i, zeros(Int,  38)) for i in 41:GROUPSIZE * 5]
linke = [Negotiator(i, i, zeros(Int, 38)) for i in 51:GROUPSIZE * 6]
ssw = [Negotiator(i, i, zeros(Int, 38)) for i in 61:GROUPSIZE * 7]






