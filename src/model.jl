mutable struct Agent
    id::Integer
    party::String  # Symbol?
    opinions::AbstractArray
end


mutable struct Model
    parameter_set::ParameterSet
    opinions::AbstractDict
    agents::Array{Agent}
    negotiation_sequence::AbstractArray
end

# Create a model from given configurations
function setup_model(
    params::ParameterSet,
    opinions::AbstractDict,
    negotiation_sequence::AbstractArray
)
    n_agents = length(params.negotiation_parties) * params.groupsize
    agent_ids = 1:n_agents
    agent_parties = reduce(vcat, [repeat([party], params.groupsize) for party in params.negotiation_parties])
    agent_opinions = [opinions[Symbol(party)] for party in agent_parties]
    agents = [Agent(i, p, o) for (i, p, o) in zip(agent_ids, agent_parties, agent_opinions)]
    return Model(
        params,
        opinions,
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
