using Agents
using LightGraphs
using StatsBase
using Random
using CSV
using DataFrames
using Combinatorics

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
function negotiation!(negotiators, parties::AbstractArray)
    participants = filter(negotiator -> negotiator.party in parties, negotiators)
    n_participants = length(participants)
    space = Agents.GraphSpace(LightGraphs.complete_graph(n_participants))
    model = Agents.ABM(Negotiator, space)
    populate!(model, participants)
    adata, mdata = run!(model, agent_step!, model_step!, 1, adata=[:opinions, :party], obtainer=deepcopy)
    return negotiators
end

# Extract opinion vectors from the formatted wahlomat data
function get_party_opinions(party_name, data)
    opinions = filter(data -> data.party_shorthand == party_name, data)
    opinions = collect(opinions[1, 3:40])
    return opinions
end

# Setup negotiator groups
function setup_negotiators(groupsize, party_names, data)
    n_agents = length(party_names) * groupsize
    party_id = 1
    negotiators = []
    for party_id in 1:length(party_names)
        curr_party_opinions = get_party_opinions(party_names[party_id], data)
        for j in 1:groupsize
            agent = Negotiator((party_id - 1) * groupsize + j, 
                               party_id * j,
                               deepcopy(curr_party_opinions),
                               party_names[party_id])
            push!(negotiators, agent)
        end
    end
    return negotiators
end

# Get all n-combinations of the parties
function get_party_combinations(party_names, n=2)
    combs = combinations(party_names, n)
    return combs
end

# Run given sequence of party negotiations
function meta_run!(negotiators, party_combinations)
    init_negotiators = DataFrame(deepcopy(negotiators))
    init_negotiators[!, :step] .= 0
    results = [init_negotiators]
    for (i, pp) in enumerate(party_combinations)
        negotiation!(negotiators, pp)
        curr_negotiators = DataFrame(deepcopy(negotiators))
        curr_negotiators[!, :step] .= i
        push!(results, curr_negotiators)
    end
    results = vcat(results...)
    return results
end

# Use actual data to initialize agents
party_names = ["SPD", "CDU_CSU", "GRUENE", "FDP", "AfD", "DIE_LINKE", "SSW"]
data = CSV.read(joinpath("data", "data_wide.csv"), DataFrame)
data = filter(data -> data.party_shorthand in party_names, data)

# Test
negotiators = setup_negotiators(1, party_names, data)
combs = get_party_combinations(party_names, 2)
res = meta_run!(negotiators, combs)

# TODO:
#   * refactor
#   * use "ordinal" axelrod




