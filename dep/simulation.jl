"""
    similarity(sender::Agent, receiver::Agent)

Compute the ordinal similarity of two agents.
Argument names are chosen to match assimilate! function.
"""
function similarity(sender::Agent, receiver::Agent)
    absolute_difference = sum(abs.(sender.opinions .- receiver.opinions))
    highest_possible_difference = 2 * length(sender.opinions)
    return 1 - (absolute_difference / highest_possible_difference)
end
