"""
    simulate(model::Model, replicates::Int)

Run a model `replicates` number of times for every possible sequence of meetings.
"""
function simulate(model::Model, replicates::Int)
    sequences = permutations(collect(combinations(model.parameter_set.parties, 2)))
    sequence_data_list = DataFrame[]
    @showprogress 1 "Running simulations..." for (seq_idx, seq) in enumerate(sequences)
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
    seq_data = format_data_for_database(seq_data)
    return seq_data
end


# prepare data for database
function format_data_for_database(data::DataFrame)
    reshaped_array = []
    for i in 1:length(data.opinions[1])
        current_statement = []
        for j in 1:length(data.opinions)
            push!(current_statement, data.opinions[j][i])
        end
        push!(reshaped_array, deepcopy(current_statement))
    end
    right_side = DataFrame(reshaped_array, :auto)
    right_side_names = Symbol.(1:ncol(right_side))
    rename!(right_side, right_side_names)
    left_side = select(data, Not(:opinions))
    data_formatted = hcat(left_side, right_side)
    data_formatted = stack(data_formatted, 5:ncol(data_formatted))  # TODO: not ideal, better with pattern matching by column name?
    rename!(data_formatted, Dict(:id => :agent_id, :variable => :statement, :value => :position))
    return data_formatted
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
