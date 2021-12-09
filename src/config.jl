mutable struct ParameterSet
    group_size::Int
    parliament::AbstractDict
    parliament_size::Int
    parliament_majority::Int
    required_consensus::Float64
    parties::AbstractArray
    opinions::AbstractDict
end

function Base.show(io::IO, params::ParameterSet)
    print(
        """
        ParameterSet with negotiator groups of size $(params.group_size)
        parliament: $(params.parliament_size) seats, required majority is $(params.parliament_majority)
        parties included in the negotiations: $(params.parties)
        """
    )
end

function read_config(config_path::String)
    config_dict = YAML.load_file(config_path)
    opinions_dataframe = CSV.read(config_dict["data_path"], DataFrame)
    opinions = Dict()
    for r in eachrow(opinions_dataframe)
        if r.party_shorthand in config_dict["parties"]
            # TODO: improve
            #       not ideal that the data scheme must be exactly right for this to work
            opinions[Symbol(r.party_shorthand)] = collect(r[3:end])
        end
    end
    params = ParameterSet(
        config_dict["group_size"],
        config_dict["parliament"],
        sum(values(config_dict["parliament"])),
        config_dict["parliament_majority"],
        config_dict["required_consensus"],
        config_dict["parties"],
        opinions
    )
    return params
end


