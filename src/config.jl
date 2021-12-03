struct Config
    all_seats::Int
    majority_requirement::Int
    seat_distribution::AbstractDict
    party_names_all::AbstractArray
    party_names::AbstractArray
    opinion_data::DataFrame
    function Config(
        all_seats,
        majority_requirement,
        seat_distribution,
        party_names_all,
        party_names,
        opinion_data
    )
        return new(
            all_seats,
            majority_requirement,
            seat_distribution,
            party_names_all,
            party_names,
            opinion_data
        )
    end
end

function Config(config_path::String)
    cfg_dict = YAML.load_file(config_path)
    data = CSV.read(cfg_dict["data_path"], DataFrame)
    data = filter(data -> data.party_shorthand in cfg_dict["party_names"], data)
    return Config(
        cfg_dict["all_seats"],
        cfg_dict["majority_requirement"],
        cfg_dict["seat_distribution"],
        cfg_dict["party_names_all"],
        cfg_dict["party_names"],
        data
    )
end
