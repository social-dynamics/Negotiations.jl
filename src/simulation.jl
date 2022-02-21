"""
    simulate(model::Model, rule::Rule, replicates::Int, db::Sqlite.DB; batchname::String, seed::Int)

Run a model `replicates` number of times with a given `rule` for every possible sequence of meetings.
"""
function simulate(
    model::Model, rule::Rule, replicates::Int, db::SQLite.DB;
    batchname::String, seed::Int = 1
)
    register_model!(db, model, batchname)
    Random.seed!(seed)
    sequences = permutations(collect(combinations(model.parameter_set.parties, 2)))
    @showprogress 1 "Running simulations..." for (seq_idx, seq) in enumerate(sequences)
        results_data = @chain begin
            run_model_on_sequence(model, rule, seq, replicates)
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
    register_model!(db::SQLite.DB, model::Model, batchname::String)

Register a given model in the simulation database.
"""
function register_model!(db::SQLite.DB, model::Model, batchname::String)
    parliament_table = stack(DataFrame(sort(collect(model.parameter_set.parliament))), Not([]))
    rename!(parliament_table, [:party_shorthand, :seats])
    parliament_table[!, :batchname] .= batchname
    parameters_table = DataFrame(
        batchname = batchname,
        group_size = model.parameter_set.group_size,
        parliament_majority = model.parameter_set.parliament_majority,
        required_consensus = model.parameter_set.required_consensus
    )
    SQLite.load!(parliament_table, db, "parliament")
    SQLite.load!(parameters_table, db, "parameters")
    return true
end


"""
    run_sequence(sequence::AbstractArray, replicates::Int)

Run the model `replicates` times for a given `sequence`.
"""
function run_model_on_sequence(model::Model, rule::Rule, sequence::AbstractArray, replicates::Int)
    replicate_list = DataFrame[]
    # TODO: figure out how much can be parallelized and how
    @sync @distributed for rep in 1:replicates
        model_tracker = deepcopy(model)
        rep_data = snap(DataFrame(deepcopy(model_tracker.agents)), :step, 0)  # track initial configuration
        for (step, comb) in enumerate(sequence)
            meeting = Meeting(model_tracker, comb)  # we are in a meeting now
            # TODO:
            #   * maybe plug-and-play with different opinion dynamics models
            #   * This might be a modular part where different models can be used
            # begin
            #     for topic in 1:length(meeting.agents[1].opinions)  # iterate over all opinions
            #         for _ in 1:100  # scaling of homophily can be done via the stubbornness / inertia parameter (to be introduced later)
            #             negotiators = StatsBase.sample(meeting.participants, 2)
            #             negotiators_opinions = [agent.opinions[topic] for agent in negotiators]
            #             for (i, agent) in enumerate(negotiators)  # in principle, this allows for more than 2-way exchanges
            #                 w = ones(length(negotiators_opinions))
            #                 w[i] = 10.0  # again: stubbornness / inertia parameter?
            #                 agent.opinions[topic] = StatsBase.mean(negotiators_opinions, StatsBase.weights(w))
            #             end
            #         end
            #     end
            # end
            rule.update!(meeting)

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
    snap(data::DataFrame, scope::Symbol, val::Union{Int, String})

Make a snapshot of the simulation data at `val` at `scope`.
"""
function snap(data::DataFrame, scope::Symbol, val::Union{Int, String})
    data[!, scope] .= val
    return data
end
