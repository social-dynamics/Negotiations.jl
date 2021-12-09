mutable struct Agent
    id::Integer
    party::String  # Symbol?
    opinions::AbstractArray
end

mutable struct Model
    parameter_set::ParameterSet
    agents::Array{Agent}
    negotiation_sequence::AbstractArray
end

# Create a model from given configurations
function setup_model(params::ParameterSet, negotiation_sequence::AbstractArray)
    n_agents = length(params.parties) * params.group_size
    agent_ids = 1:n_agents
    agent_parties = reduce(vcat, [repeat([party], params.group_size) for party in params.parties])
    agent_opinions = [params.opinions[Symbol(party)] for party in agent_parties]
    agents = [Agent(i, p, o) for (i, p, o) in zip(agent_ids, agent_parties, agent_opinions)]
    return Model(
        params,
        agents,
        negotiation_sequence
    )
end

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
