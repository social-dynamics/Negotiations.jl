function can_form_government(model::Model)
    party_combs = all_party_combinations(model)
    seats = [combined_seats(model, comb) for comb in party_combs]
    party_consensus_dict = Dict(party => party_consensus(model, party) for party in model.parameter_set.parties)
    pairwise_similarities = [pair_similarities(pc, party_consensus_dict) for pc in party_combs]
    have_consensus_list = [have_consensus(model, s) for s in pairwise_similarities]
    return sum(have_consensus_list) == 1
end

function have_consensus(model::Model, similarities::AbstractArray)
    entrywise_have_consensus = [s .> model.parameter_set.required_consensus for s in similarities]
    return sum(entrywise_have_consensus) == length(entrywise_have_consensus)
end

function all_party_combinations(model::Model)
    return collect(Combinatorics.combinations(model.parameter_set.parties))
end


function combined_seats(model::Model, parties::AbstractArray)
     return sum([model.parameter_set.parliament[party] for party in parties])
end


function pair_similarities(parties::AbstractArray, party_consensus_dict::AbstractDict)
    all_pairs = Combinatorics.combinations(parties, 2)
    similarities = [
        similarity([party_consensus_dict[pair[1]], party_consensus_dict[pair[2]]])
        for pair in all_pairs
    ]
    return similarities
end


function similarity(opinions::AbstractArray)
    1 - (sum(abs.(opinions[1] .- opinions[2])) / (2 * length(opinions[1])))
end


function party_consensus(model, party)
    agents = filter(a -> a.party == party, model.agents)
    opinions = [a.opinions for a in agents]
    consensus = [
        StatsBase.mode([o[i] for o in opinions])
        for i in 1:length(model.opinions[Symbol(party)])
    ]
    return consensus
end
