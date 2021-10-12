using Agents
using LightGraphs
using StatsBase
using Random
using CSV
using DataFrames

# The agent type
@agent Negotiator{} Agents.GraphAgent begin
    opinions::AbstractArray
    party::String
end

# Dummy function for agent step, the real stuff happens in model_step!
function agent_step!(agent, model)
    return agent
end

# Axelrod rule
function assimilate!(agent1, agent2)
    similarity = sum(agent1.opinions .== agent2.opinions) / length(agent1.opinions)
    if Random.rand() < similarity
        dim_to_switch = Random.rand(1:length(agent1.opinions))  # TO DO: choose at random
        agent1.opinions[dim_to_switch] = copy(agent2.opinions[dim_to_switch])  # TO DO: implement ordinal Axelrod
    end
    return agent1, agent2
end

# Run once every step to update model parameters
function model_step!(model::Agents.ABM)
    for i in 1:100000
        agent1 = random_agent(model)
        agent2 = random_agent(model)
        assimilate!(agent1, agent2)
    end
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

# The "meta" model step: a selection of parties negotiate
function negotiation(negotiators, parties::AbstractArray)
    participants = filter(negotiator -> negotiator.party in parties, negotiators)
    n_participants = length(participants)
    space = Agents.GraphSpace(LightGraphs.complete_graph(n_participants))
    model = Agents.ABM(Negotiator, space)
    populate!(model, participants)
    adata, mdata = run!(model, agent_step!, model_step!, 1, adata=[:opinions, :party], obtainer=deepcopy)
    return adata
end

# TO DO: use actual data to initialize agents
data = CSV.read(joinpath("data", "data_wide.csv"), DataFrame)

# Setup negotiator groups
party_names = ["SPD", "CDU_CSU", "GRUENE", "FDP", "AfD", "DIE_LINKE", "SSW"]
GROUPSIZE = 10
n_agents = length(party_names) * GROUPSIZE
party_id = 1
negotiators = []
for party_id in 1:length(party_names)
    for j in 1:GROUPSIZE
        push!(negotiators,
              Negotiator((party_id - 1) * GROUPSIZE + j, 
                         party_id * j, 
                         [Random.rand(1:10) for i in 1:38],
                         party_names[party_id]))
    end
end

function get_party_opinions(party_name, data)
    opinions = filter(data -> data.party_shorthand == party_name, data)
    opinions = collect(data[1, 3:40])
    return opinions
end

data = filter(data -> data.party_shorthand in party_names, data)

# Test
# negotiation(negotiators, ["GRUENE", "FDP"])


# TODO:
#   * initialize agents with actual wahlomat data
#   * wrap initialization in function(s)
#   * write a meta run! function that tracks the changes in the negotiator list





