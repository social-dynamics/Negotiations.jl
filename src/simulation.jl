"""
    run_model(model::Model, replicates::Int)

Run a model `replicates` number of times for every possible sequence of meetings.
"""
function simulate(model::Model, replicates::Int)
    sequences = permutations(collect(combinations(model.parameter_set.parties, 2)))
    sequence_data_list = DataFrame[]
    for (seq_idx, seq) in enumerate(sequences)
        seq_data = run_sequence(model, seq, replicates)
        push!(sequence_data_list, snap(seq_data, :seq, seq_idx))
    end
    data = reduce(vcat, sequence_data_list)
    return collect(sequences), data
end


"""
    run_sequence(sequence::AbstractArray, replicates::Int)

Run the model `replicates` times for a given `sequence`.
"""
function run_sequence(model::Model, sequence::AbstractArray, replicates::Int)
    rep_data_list = DataFrame[]
    for rep in 1:replicates
        model_tracker = deepcopy(model)
        rep_data = snap(DataFrame(deepcopy(model_tracker.agents)), :step, 0)  # track initial configuration
        for (step, comb) in enumerate(sequence)
            meeting = Meeting(model_tracker, comb)
            counter = 0
            for i in 1:10000  # TODO: write convergence criterion
                negotiators = StatsBase.sample(meeting.participants, 2)
                topic = Random.rand(1:length(negotiators[1].opinions))
                new_opinions = get_new_opinions(negotiators, topic)
                for i in 1:length(new_opinions)
                    negotiators[i].opinions[topic] = new_opinions[i]
                end
            end
            step_data = DataFrame(deepcopy(model_tracker.agents))
            rep_data = reduce(vcat, [rep_data, snap(step_data, :step, step)])
        end
        push!(rep_data_list, snap(deepcopy(rep_data), :rep, rep))
    end
    seq_data = reduce(vcat, rep_data_list)
    return seq_data
end


"""
    get_new_opinions(negotiators::Array{Agent}, topic::Int)

Get new opinions on `topic` after interaction of `negotiators`.
"""
function get_new_opinions(negotiators::Array{Agent}, topic::Int)
    opinions = [agent.opinions[topic] for agent in negotiators]
    new_opinions = []
    for i in 1:length(opinions)
        w = ones(length(negotiators))
        w[i] = 2.0  # TODO: could be a stubbornness parameter to the model
        push!(new_opinions, StatsBase.mean(opinions, weights(w)))
    end
    return new_opinions
end


"""
    snap(data::DataFrame, scope::Symbol, val::Int)

Make a snapshot of the simulation data at `val` at `scope`.
"""
function snap(data::DataFrame, scope::Symbol, val::Int)
    data[!, scope] .= val
    return data
end


"""
    assimilate!(sender::Agent, receiver::Agent)

Change one of the receiver's opinions to sender's opinion.
"""
function assimilate!(sender::Agent, receiver::Agent)
    i = Random.rand(1:length(sender.opinions))
    receiver.opinions[i] = StatsBase.mean([sender.opinions[i], receiver.opinions[i]])
    return receiver
end
