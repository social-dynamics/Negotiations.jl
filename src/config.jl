"""
    ParameterSet

A set of parameters with which the model will be run.
"""
mutable struct ParameterSet
    group_size::Int
    parliament::AbstractDict
    parliament_size::Int
    parliament_majority::Int
    required_consensus::Float64
    parties::AbstractArray
    opinions::DataFrame
end


# Constructor with keyword arguments
ParameterSet(;
    group_size,
    parliament,
    parliament_size,
    parliament_majority,
    required_consensus,
    parties,
    opinions
) = ParameterSet(
    group_size,
    parliament,
    parliament_size,
    parliament_majority,
    required_consensus,
    parties,
    opinions
)


function Base.show(io::IO, params::ParameterSet)
    print(
        """
        ParameterSet with negotiator groups of size $(params.group_size)
        parliament: $(params.parliament_size) seats, required majority is $(params.parliament_majority)
        parties included in the negotiations: $(params.parties)
        """
    )
end


"""
    read_config(config_path::String)

Load a YAML config file and turn it into a `ParameterSet`.
"""
function read_config(config_path::String)
    config_dict = YAML.load_file(config_path)
    db = SQLite.DB(config_dict["data_path"])
    opinions = extract_opinions(db)
    params = ParameterSet(
        group_size = config_dict["group_size"],
        parliament = config_dict["parliament"],
        parliament_size = calculate_parliament_size(config_dict),
        parliament_majority = config_dict["parliament_majority"],
        required_consensus = config_dict["required_consensus"],
        parties = config_dict["parties"],
        opinions = opinions
    )
    return params, db
end


"""
    extract_opinions(config_dict::AbstractDict)

Extract opinions from a given `config_dict` from a parsed YAML.
This function is called in `read_config`.
"""
function extract_opinions(db::SQLite.DB)
    return DBInterface.execute(
        db,
        """
        SELECT party_id, statement_id, position
        FROM opinion
        """
    ) |> DataFrame
end


"""
    calculate_parliament_size(config_dict::AbstractDict)

Calculate the number of seats of the parliament given by a `config_dict`.
The `config_dict` is a parsed YAML file (see `read_config`).
"""
function calculate_parliament_size(config_dict::AbstractDict)
    return sum(values(config_dict["parliament"]))
end
