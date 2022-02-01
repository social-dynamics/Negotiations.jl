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
end


"""
    setup_model(params::ParameterSet, db::SQLite.DB)

Create a model from a given set of specifications and a database.
"""
function setup_model(params::ParameterSet, db::SQLite.DB)
    agents = create_agents(params, db)
    return Model(params, agents)
end


"""
    create_agents(params::ParameterSet)

Create a vector of agents with the specifications from a `ParameterSet`.
"""
function create_agents(params::ParameterSet, db::SQLite.DB)
    agent_parties = reduce(vcat, fill.(params.parties, params.group_size))
    opinions = Dict(
        party => filter(p -> p.party_shorthand == party, party_opinions_view(db)).position
        for party in params.parties
    )
    agent_opinions = [opinions[party] for party in agent_parties]
    agents = [
        Agent(i, p, deepcopy(o))
        for (i, (p, o)) in enumerate(zip(agent_parties, agent_opinions))
    ]
    return agents
end


"""
    party_opinions_view(db::SQLite.DB)

Return a dataframe with party, statement and held position on that statement.
"""
function party_opinions_view(db::SQLite.DB)
    return DBInterface.execute(
        db,
        """
        SELECT party_shorthand, statement_id, position
        FROM opinion JOIN party
        ON opinion.party_id = party.party_id
        """
    ) |> DataFrame
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
