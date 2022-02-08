"""
    simulate(model::Model, replicates::Int)

Run a model `replicates` number of times for every possible sequence of meetings.
"""
function simulate(
    model::Model, replicates::Int, db::SQLite.DB;
    batchname::String = "simulation", seed::Int = 1
)
    Random.seed!(seed)
    sequences = permutations(collect(combinations(model.parameter_set.parties, 2)))
    @showprogress 1 "Running simulations..." for (seq_idx, seq) in enumerate(sequences)
        results_data = @chain begin
            run_model_on_sequence(model, seq, replicates)
            snap(_, :seq, seq_idx)
            snap(_, :batchname, batchname)
        end
        SQLite.load!(results_data, db, "results")
    end
    sequences_data = @chain begin
        format_sequences_for_db(sequences)
        snap(_, :batchname, batchname)
    end
    SQLite.load!(sequences_data, db, "sequences")
    return true
end


"""
    run_sequence(sequence::AbstractArray, replicates::Int)

Run the model `replicates` times for a given `sequence`.
"""
function run_model_on_sequence(model::Model, sequence::AbstractArray, replicates::Int)
    replicate_list = DataFrame[]
    # TODO: figure out how much can be parallelized and how
    @sync @distributed for rep in 1:replicates
        model_tracker = deepcopy(model)
        rep_data = snap(DataFrame(deepcopy(model_tracker.agents)), :step, 0)  # track initial configuration
        for (step, comb) in enumerate(sequence)
            meeting = Meeting(model_tracker, comb)
            # TODO: maybe plug-and-play with different opinion dynamics models
            # TODO: this implementation is crap -> improve
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
        push!(replicate_list, snap(deepcopy(rep_data), :rep, rep))
    end
    seq_data = reduce(vcat, replicate_list)
    seq_data = format_results_for_db(seq_data)
    return seq_data
end


"""
    format_results_for_db(data::DataFrame)

Format the simulation data for storage in the database.
"""
function format_results_for_db(data::DataFrame)
    reshaped_array = []
    for i in 1:length(data.opinions[1])
        current_statement = []
        for j in 1:length(data.opinions)
            push!(current_statement, data.opinions[j][i])
        end
        push!(reshaped_array, deepcopy(current_statement))
    end
    left_side = select(data, Not(:opinions))
    right_side = @chain begin
        DataFrame(reshaped_array, :auto)
        rename(_, Symbol.(1:ncol(_)))
    end
    data_formatted = @chain begin
        hcat(left_side, right_side)
        stack(_, 5:ncol(_))  # TODO: not ideal, better with pattern matching by column name?
        # stack(_, [col for col in names(_) if occursin(r"[0-9]*", string(col))])
        rename(_, Dict(:id => :agent_id, :variable => :statement_id, :value => :position))
    end
    return data_formatted
end


"""
    format_sequences_for_db(sequences)

Formats a sequence generator for storage in a result database.
"""
function format_sequences_for_db(sequences)
    df = DataFrame()
    for (i, seq) in enumerate(sequences)
        for (j, mtg) in enumerate(seq)
            push!(df, (seq_id = i, step = j, party_1 = mtg[1], party_2 = mtg[2]))
        end
    end
    return df
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
    snap(data::DataFrame, scope::Symbol, val::Union{Int, String})

Make a snapshot of the simulation data at `val` at `scope`.
"""
function snap(data::DataFrame, scope::Symbol, val::Union{Int, String})
    data[!, scope] .= val
    return data
end
