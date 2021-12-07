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


