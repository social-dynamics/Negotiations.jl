"""
    Agent

The agent type for the party negotiation model.
"""
mutable struct Agent
    id::Integer
    party::String  # Symbol? -> some sort of Enum?
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
    negotiation_sequence::Vector{Vector{String}},
    db::SQLite.DB
)
    agents = create_agents(params, db)
    return Model(params, agents, negotiation_sequence)
end


# TODO: currently broken due to updated config procedure
# TODO: refactor, this can be simplified
"""
    create_agents(params::ParameterSet)

Create a vector of agents with the specifications from a `ParameterSet`.
"""
function create_agents(params::ParameterSet, db::SQLite.DB)
    n_agents = length(params.parties) * params.group_size
    agent_ids = 1:n_agents
    agent_parties = reduce(
        vcat,
        [repeat([party], params.group_size) for party in params.parties]
    )
    opinions_with_party = DBInterface.execute(
        db,
        """
        SELECT party_shorthand, statement_id, position
        FROM opinion JOIN party
        ON opinion.party_id = party.party_id
        """
    ) |> DataFrame
    opinions = Dict(
        party => filter(
            p -> p.party_shorthand == party,
            opinions_with_party
           ).position
        for party in params.parties
    )
    agent_opinions = [opinions[party] for party in agent_parties]
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
