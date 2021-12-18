"""
    Agent

The agent type for the party negotiation model.
"""
mutable struct Agent
    id::Integer
    party::String  # Symbol?
    opinions::AbstractArray
end


"""
    Model

The model type for the party negotiation model.
"""
mutable struct Model
    parameter_set::ParameterSet
    agents::Array{Agent}
    negotiation_sequence::Vector{Vector{String}}
end


"""
    setup_model(params::ParameterSet, negotiation_sequence::Vector{Vector{String})

Create a model from a given set of specifications.
"""
function setup_model(
    params::ParameterSet,
    negotiation_sequence::Vector{Vector{String}}
)
    agents = create_agents(params)
    return Model(params, agents, negotiation_sequence)
end


"""
    create_agents(params::ParameterSet)

Create a vector of agents with the specifications from a `ParameterSet`.
"""
function create_agents(params::ParameterSet)
    n_agents = length(params.parties) * params.group_size
    agent_ids = 1:n_agents
    agent_parties = reduce(
        vcat,
        [repeat([party], params.group_size) for party in params.parties]
    )
    agent_opinions = [params.opinions[Symbol(party)] for party in agent_parties]
    agents = [
        Agent(i, p, deepcopy(o)) 
        for (i, p, o) in zip(agent_ids, agent_parties, agent_opinions)
    ]
    return agents
end


"""
    Meeting

When running a `Model`, each step is performed in a `Meeting`.
"""
mutable struct Meeting
    participants::Array{Agent}
    function Meeting(model::Model, comb::AbstractArray)
        participants = filter(a -> a.party in comb, model.agents)
        new(participants)
    end
end


function Base.show(io::IO, model::Model)
    print(
        """
        Model with $(length(model.agents)) agents from $(length(model.parameter_set.parties)) parties
        """
    )
end
