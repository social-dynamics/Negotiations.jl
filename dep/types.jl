# The agent type
@agent Negotiator{} Agents.GraphAgent begin
    opinions::AbstractArray
    party::String
end

# The model type
mutable struct NegotiationModel
    config::Config
    negotiators::Array{Negotiator}

    # model code here
end
