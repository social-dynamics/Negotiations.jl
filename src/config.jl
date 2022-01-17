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
end


# Constructor with keyword arguments
ParameterSet(;
    group_size,
    parliament,
    parliament_size,
    parliament_majority,
    required_consensus,
    parties
) = ParameterSet(
    group_size,
    parliament,
    parliament_size,
    parliament_majority,
    required_consensus,
    parties
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
    parameter_set_from_config(config_path::String)

Factory method to create a ParameterSet from a YAML configuration file.
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

Load a database from a given path.
"""
function load_database(db_path::String)
    db = SQLite.DB(db_path)
    @assert conforms_to_schema(db) "The database you provided is not suitable for this model."
    return db
end


# TODO: works, but requires refactoring
"""
    conforms_to_schema(db::SQLite.DB)

Check if a given database conforms to the schema required by Negotiations.jl.
"""
function conforms_to_schema(db::SQLite.DB)
    # with some friendly help from:
    # -- https://stackoverflow.com/questions/6460671/sqlite-schema-information-metadata

    schema_df = DBInterface.execute(db, """
        SELECT name, sql
        FROM sqlite_master
        WHERE type='table'
        ORDER BY name
    """) |> DataFrame

    opinion_schema = "CREATE TABLE opinion\n(\n    party_id INTEGER NOT NULL,\n    statement_id INTEGER NOT NULL,\n    position INTEGER,\n    position_rationale TEXT,\n    FOREIGN KEY(party_id) REFERENCES party(party_id),\n    FOREIGN KEY(statement_id) REFERENCES statement(statement_id),\n    PRIMARY KEY(party_id, statement_id)\n)"

    party_schema = "CREATE TABLE party\n(\n    party_id INTEGER NOT NULL PRIMARY KEY,\n    party_shorthand TEXT,\n    party_name TEXT\n)"

    statement_schema = "CREATE TABLE statement\n(\n    statement_id INTEGER NOT NULL PRIMARY KEY,\n    statement_title TEXT,\n    statement TEXT\n)"

    return (
        (schema_df.sql[1] == opinion_schema)
        & (schema_df.sql[2] == party_schema)
        & (schema_df.sql[3] == statement_schema)
    )

end


"""
    opinions_view(config_dict::AbstractDict)

Extract opinions from a given `config_dict` from a parsed YAML.
This function is called in `read_config`.
"""
function opinions_view(db::SQLite.DB)
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


