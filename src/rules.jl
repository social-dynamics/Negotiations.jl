abstract type Rule end


"""
    RealPolitics()

Nobody ever changes their mind.
"""
struct RealPolitics <: Rule
    update!::Function
    function RealPolitics()
        new(x -> x)
    end
end


"""
    BoundedConfidence(; bc::AbstractFloat, inertia::AbstractFloat)

Update rule for a `Meeting` based on bounded confidence model, but with additional `inertia`.
"""
struct BoundedConfidence <: Rule
    update!::Function
    function BoundedConfidence(; bc::AbstractFloat, inertia::AbstractFloat)
        new(get_bounded_confidence_func(bc, inertia))
    end
end


"""
    get_bounded_confidence_func(bc::AbstractFloat, inertia::AbstractFloat)

Generator function for the `BoundedConfidence` update rule.
"""
function get_bounded_confidence_func(bc::AbstractFloat, inertia::AbstractFloat)
    function update!(meeting::Meeting; bc = bc, inertia = inertia)
        for topic in 1:length(meeting.participants[1].opinions)
            for _ in 1:100
                negotiators = StatsBase.sample(meeting.participants, 2)
                # TODO: refactor if more negotiators in consideration
                if abs(negotiators[1].opinions[topic] - negotiators[2].opinions[topic]) <= bc
                    negotiators_opinions = [agent.opinions[topic] for agent in negotiators]
                    for (i, agent) in enumerate(negotiators)
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


"""
    ContinuousHomophily(; inertia::AbstractFloat)

Update rule based on homophily principle with `inertia` parameter.
"""
struct ContinuousHomophily <: Rule
    update!::Function
    function ContinuousHomophily(; inertia::AbstractFloat)
        new(get_continuous_homophily_func(inertia))
    end
end


"""
    get_continuous_homophily_func(inertia::AbstractFloat)

Generator function for `ContinuousHomophily` update rule.
"""
function get_continuous_homophily_func(inertia::AbstractFloat)
    function update!(meeting::Meeting; inertia=inertia)
        for topic in 1:length(meeting.participants[1].opinions)
            for _ in 1:100
                negotiators = StatsBase.sample(meeting.participants, 2)
                # TODO: refactor if more negotiators in consideration
                negotiators_opinions = [agent.opinions[topic] for agent in negotiators]
                for (i, agent) in enumerate(negotiators)
                    w = ones(Float64, length(negotiators_opinions))
                    w[i] = inertia * abs(negotiators[1].opinions[topic] - negotiators[2].opinions[topic])
                    agent.opinions[topic] = StatsBase.mean(negotiators_opinions, StatsBase.weights(w))
                end
            end
        end
        return meeting
    end
    return update!
end
