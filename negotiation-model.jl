using Agents
using LightGraphs


# The agent type
@agent Negotiator{} Agents.GraphAgent begin
    opinions::AbstractArray
end

# Actions that each agent performs in each step
function agent_step!(agent::Negotiator, model::Agents.ABM)
    return model
end

# Axelrod rule
function assimilate!()
    
end

# Run once every step to update model parameters
function model_step!(model::Agents.ABM)
    return model
end

# Populate a model with agents
function populate!(model::Agents.ABM, negotiator_group::AbstractArray)
    for i in 1:nv(model.space.graph)
        add_agent!(negotiator_group[i], i, model)
    end
    return model
end

function negotiation(parties::AbstractArray)
    n_participants = length(parties)
    space = Agents.GraphSpace(LightGraphs.complete_graph(n_participants * GROUPSIZE))
    model = Agents.ABM(Negotiator, space)
    populate!(model, vcat(parties...))
    adata, mdata = run!(model, agent_step!, model_step!, 100, adata=[:opinions], obtainer=deepcopy)
    return adata
end

# Setup (TO DO: wrap into functions)
GROUPSIZE = 10
space = Agents.GraphSpace(LightGraphs.complete_graph(GROUPSIZE))
model = Agents.ABM(Negotiator, space)

# Setup negotiator groups
spd = [Negotiator(i, i, []) for i in 1:GROUPSIZE]
cdu = [Negotiator(i, i, []) for i in 11:GROUPSIZE * 2]
gruene = [Negotiator(i, i, []) for i in 21:GROUPSIZE * 3]
fdp = [Negotiator(i, i, []) for i in 31:GROUPSIZE * 4]
afd = [Negotiator(i, i, []) for i in 41:GROUPSIZE * 5]
linke = [Negotiator(i, i, []) for i in 51:GROUPSIZE * 6]
ssw = [Negotiator(i, i, []) for i in 61:GROUPSIZE * 7]






