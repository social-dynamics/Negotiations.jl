function StatsBase.sample(model::Model, n::Int)
    return reduce(vcat, [snap_rep(simulate(model), rep) for rep in 1:n])
end


function simulate(model::Model)
    model_tracker = deepcopy(model)
    data = snap_step(model_tracker, 0)
    for (i, comb) in enumerate(model.negotiation_sequence)
        meeting = Meeting(model_tracker, comb)
        for i in 1:10000  # TODO: write confergence criterion
            negotiators = StatsBase.sample(meeting.participants, 2)
            if Random.rand() < similarity(negotiators...)
                assimilate!(negotiators...)
            end
        end
        data = reduce(vcat, [data, snap_step(model_tracker, i)])
    end
    return data
end

function snap_rep(data::DataFrame, rep::Int)
    data[!, :rep] .= rep
    return data
end

function snap_step(model::Model, i::Int)
    data = DataFrame(deepcopy(model.agents))
    data[!, :step] .= i
    return data
end

function assimilate!(sender::Agent, receiver::Agent)
    i = Random.rand(1:length(sender.opinions))
    receiver.opinions[i] = sign(sender.opinions[i] + receiver.opinions[i])
    return receiver
end

function similarity(sender::Agent, receiver::Agent)
    1 - (sum(abs.(sender.opinions .- receiver.opinions)) / (2 * length(sender.opinions)))
end

