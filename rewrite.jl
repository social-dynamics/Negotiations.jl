using YAML
using CSV
using DataFrames
using StatsBase
using Random

mutable struct Agent
    id::Integer
    party::String  # Symbol?
    opinions::AbstractArray
end


### CONFIGURATION

mutable struct ParameterSet
    groupsize::Int
    n_seats::Int
    required_majority::Int
    seat_distribution::AbstractDict
    negotiation_parties::AbstractArray
end

function Base.show(io::IO, params::ParameterSet)
    # TODO: format better
    print(
        """
        ParameterSet with model specifications:
            groupsize: $(params.groupsize)
            n_seats: $(params.n_seats)
            required_majority: $(params.required_majority)
            negotiation_parties: $(params.negotiation_parties)
        """
    )
end

function read_config(config_path::String)
    config_dict = YAML.load_file(config_path)
    params = ParameterSet(
        config_dict["groupsize"],
        config_dict["all_seats"],
        config_dict["majority_requirement"],
        config_dict["seat_distribution"],
        config_dict["party_names"]
    )
    opinions_dataframe = CSV.read(config_dict["data_path"], DataFrame)
    opinions = Dict()
    for r in eachrow(opinions_dataframe)
        if r.party_shorthand in params.negotiation_parties
            opinions[Symbol(r.party_shorthand)] = collect(r[3:end])
        end
    end
    return params, opinions
end


mutable struct Model
    parameter_set::ParameterSet
    opinions::AbstractDict
    agents::Array{Agent}
    negotiation_sequence::AbstractArray
end

# Create a model from given configurations
function setup_model(
    params::ParameterSet,
    opinions::AbstractDict,
    negotiation_sequence::AbstractArray
)
    n_agents = length(params.negotiation_parties) * params.groupsize
    agent_ids = 1:n_agents
    agent_parties = reduce(vcat, [repeat([party], params.groupsize) for party in params.negotiation_parties])
    agent_opinions = [opinions[Symbol(party)] for party in agent_parties]
    agents = [Agent(i, p, o) for (i, p, o) in zip(agent_ids, agent_parties, agent_opinions)]
    return Model(
        params,
        opinions,
        agents,
        negotiation_sequence
    )
end



mutable struct Meeting
    participants::Array{Agent}
    function Meeting(model::Model, comb::AbstractArray)
        participants = filter(a -> a.party in comb, model.agents)
        new(participants)
    end
end

function StatsBase.sample(model::Model, n::Int)
    return reduce(vcat, [snap_rep(simulate(model), rep) for rep in 1:n])
end


function simulate(model::Model)
    model_tracker = deepcopy(model)
    data = snapshot(model_tracker, 0)
    for (i, comb) in enumerate(model.negotiation_sequence)
        meeting = Meeting(model_tracker, comb)
        for i in 1:10000
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



