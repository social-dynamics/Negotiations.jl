function setup_negotiators(groupsize, config)
    n_agents = length(config.party_names) * groupsize
    negotiators = []
    for party_id in 1:length(config.party_names)
        curr_party_opinions = get_party_opinions(
            config.party_names[party_id],
            config.opinion_data
        )
        for j in 1:groupsize
            agent = Negotiator((party_id - 1) * groupsize + j,
                               party_id * j,
                               deepcopy(curr_party_opinions),
                               config.party_names[party_id])
            push!(negotiators, agent)
        end
    end
    return negotiators
end

# Extract opinion vectors from the formatted wahlomat data
function get_party_opinions(party_name, data)
    opinions = filter(data -> data.party_shorthand == party_name, data)
    opinions = collect(opinions[1, 3:40])
    return opinions
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

# The "meta" model step: a selection of parties negotiate
function negotiation!(negotiators, parties::AbstractArray)
    participants = filter(negotiator -> negotiator.party in parties, negotiators)
    n_participants = length(participants)
    space = Agents.GraphSpace(Graphs.complete_graph(n_participants))
    model = Agents.ABM(Negotiator, space)
    populate!(model, participants)
    adata, mdata = run!(model, agent_step!, model_step!, 1, adata=[:opinions, :party], obtainer=deepcopy)
    return negotiators
end

# Populate a model with agents
function populate!(model::Agents.ABM, negotiator_group::AbstractArray)
    negotiator_group = vcat(negotiator_group...)
    for i in 1:nv(model.space.graph)
        add_agent!(negotiator_group[i], i, model)
    end
    return model
end

# Dummy function for agent step, the real stuff happens in model_step!
function agent_step!(agent, model)
    return agent
end

# Run once every step to update model parameters
function model_step!(model::Agents.ABM)
    for i in 1:100000  # convergence criterium
        agent1 = random_agent(model)
        agent2 = random_agent(model)
        if Random.rand() < similarity([agent1, agent2])
            assimilate!(agent1, agent2)
        end
    end
    return model
end

# Axelrod rule
function assimilate!(agent1, agent2)
    i = Random.rand(1:length(agent1.opinions))
    agent1.opinions[i] = sign(agent1.opinions[i] + agent2.opinions[i])
    return agent1, agent2
end

# Ordinal similarity
function similarity(agents::Array{Negotiator})  # TODO: refactor
    1 - (sum(abs.(agents[1].opinions .- agents[2].opinions)) / (2 * length(agents[1].opinions)))
end

function similarity(opinions::AbstractArray)
    1 - (sum(abs.(opinions[1] .- opinions[2])) / (2 * length(opinions[1])))
end

# TODO: fix bug
function can_form_government(parties, negotiators, seats, consensus_requirement)
    candidates = filter(negotiators -> negotiators.party in parties, negotiators)
    sum_seats = 0
    for (k, v) in seats
        if k in parties
            sum_seats += v
        end
    end
    has_majority = sum_seats >= MAJORITY_REQUIREMENT ? true : false  # check
    # combs = collect(combinations(candidates, 2))
    # has_consensus = (sum(similarity.(combs)) / length(combs)) == 1.
    party_consensus_opinions = [party_consensus(negotiators, p) for p in parties]
    sims = [similarity(o) for o in collect(combinations(party_consensus_opinions, 2))]
    has_consensus = reduce(&, sims .> consensus_requirement)
    return has_majority & has_consensus
end

function party_consensus(negotiators, party)
    party_negotiators = filter(negotiators -> negotiators.party == party, negotiators)
    negotiator_opinions = [pn.opinions for pn in party_negotiators]
    party_consensus_opinions = [StatsBase.mode([o[i] for o in negotiator_opinions]) for i in 1:length(negotiator_opinions[1])]
    return party_consensus_opinions
end
