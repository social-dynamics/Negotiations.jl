abstract type Rule end

struct BoundedConfidence <: Rule
    update!::Function
    function BoundedConfidence(; bc::AbstractFloat, inertia::AbstractFloat)
        new(get_bounded_confidence_func(bc, inertia))
    end
end

function get_bounded_confidence_func(bc::AbstractFloat, inertia::AbstractFloat)
    function update!(meeting::Meeting; bc=bc, inertia=inertia)
        for topic in 1:length(meeting.participants[1].opinions)  # iterate over all opinions
            for _ in 1:100  # scaling of homophily can be done via the stubbornness / inertia parameter (to be introduced later)
                negotiators = StatsBase.sample(meeting.participants, 2)
                # TODO: refactor if more negotiators in consideration
                if abs(negotiators[1].opinions[topic] - negotiators[2].opinions[topic]) < bc
                    negotiators_opinions = [agent.opinions[topic] for agent in negotiators]
                    for (i, agent) in enumerate(negotiators)  # in principle, this allows for more than 2-way exchanges
                        w = ones(Float64, length(negotiators_opinions))
                        w[i] = inertia
                        agent.opinions[topic] = StatsBase.mean(negotiators_opinions, StatsBase.weights(w))
                    end
                end
            end
        end
        return meeting
    end
    return update!
end

struct Identity <: Rule
    update::Function
    function Identity()
        new(identity)
    end
end
