"""
    ParameterSet

A set of parameters with which the model will be run.
"""
Base.@kwdef mutable struct ParameterSet
    group_size::Int
    parliament::AbstractDict
    parliament_size::Int
    parliament_majority::Int
    required_consensus::Float64
    parties::AbstractArray
end


# # Constructor with keyword arguments
# ParameterSet(;
#     group_size,
#     parliament,
#     parliament_size,
#     parliament_majority,
#     required_consensus,
#     parties
# ) = ParameterSet(
#     group_size,
#     parliament,
#     parliament_size,
#     parliament_majority,
#     required_consensus,
#     parties
# )


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
    parameter_set_from_config(config_path::String)

Factory method to create a `ParameterSet` from a YAML configuration file.
"""
function parameter_set_from_config(config_path::String)
    config_dict = YAML.load_file(config_path)
    params = ParameterSet(
        group_size = config_dict["group_size"],
        parliament = config_dict["parliament"],
        parliament_size = calculate_parliament_size(config_dict),
        parliament_majority = config_dict["parliament_majority"],
        required_consensus = config_dict["required_consensus"],
        parties = config_dict["parties"]
    )
    return params
end


"""
    load_database(db_path::String)

Load a database from a given path while making sure that it conforms to the model standard.
"""
function load_database(db_path::String)
    db = SQLite.DB(db_path)
    @assert conforms_to_schema(db) "The database you provided is not suitable for this model."
    return db
end


# TODO: implement properly
"""
    conforms_to_schema(db::SQLite.DB)

Check if a given database conforms to the schema required by Negotiations.jl.
"""
function conforms_to_schema(db::SQLite.DB)
    schema_df = DBInterface.execute(db, """
        SELECT name
        FROM sqlite_master
        WHERE type='table'
        ORDER BY name
    """) |> DataFrame
    return (
        ("opinion" in schema_df.name)
        & ("party" in schema_df.name)
        & ("results" in schema_df.name)
        & ("sequences" in schema_df.name)
        & ("statement" in schema_df.name)
        # UPDATE with new tables if required
    )
end


"""
    calculate_parliament_size(config_dict::AbstractDict)

Calculate the number of seats of the parliament given by a `config_dict`.
The `config_dict` is a parsed YAML file (see `read_config`).
"""
function calculate_parliament_size(config_dict::AbstractDict)
    return sum(values(config_dict["parliament"]))
end
