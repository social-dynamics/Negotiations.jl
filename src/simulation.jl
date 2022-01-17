"""
    sample(model::Model, n::Int)

Draw n samples from a model.
"""
function StatsBase.sample(model::Model, n::Int)
    return reduce(vcat, [snap_rep(simulate(model), rep) for rep in 1:n])
end


"""
    simulate(model::Model)

Run a model once.
"""
function simulate(model::Model)
    model_tracker = deepcopy(model)
    # track initial configuration
    data = snap_step(DataFrame(deepcopy(model_tracker.agents)), 0)
    for (i, comb) in enumerate(model.negotiation_sequence)
        meeting = Meeting(model_tracker, comb)
        for i in 1:10000  # TODO: write convergence criterion
            negotiators = StatsBase.sample(meeting.participants, 2)
            if Random.rand() < similarity(negotiators...)
                assimilate!(negotiators...)
            end
            # Compare hashes of two states as convergence?
            # If same: increase counter
            # Else: counter = 0
            # If counter > k: break
            #
            # ?hash -> for hashing
            # dispatch multiple hash functions for each type
            # summarize in "deephash"
        end
        step_data = DataFrame(deepcopy(model_tracker.agents))
        data = reduce(vcat, [data, snap_step(step_data, i)])
        # if can_form_government(model)
        #     break
        # end
    end
    return data
end


"""
    snap_rep(data::DataFrame, rep::Int)

Make a snapshot of the simulation data in replicate rep.
"""
function snap_rep(data::DataFrame, rep::Int)
    data[!, :rep] .= rep
    return data
end


"""
    snap_step(data::DataFrame, rep::Int)

Make a snapshot of the simulation data in step `step`.
"""
function snap_step(data::DataFrame, step::Int)
    data[!, :step] .= step
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


"""
    similarity(sender::Agent, receiver::Agent)

Compute the ordinal similarity of two agents.
Argument names are chosen to match assimilate! function.
"""
function similarity(sender::Agent, receiver::Agent)
    absolute_difference = sum(abs.(sender.opinions .- receiver.opinions))
    highest_possible_difference = 2 * length(sender.opinions)
    return 1 - (absolute_difference / highest_possible_difference)
end
