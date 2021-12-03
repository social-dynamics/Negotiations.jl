# Documentation

This is the WIP documentation. It will change constanstly and is intended to save time during development.

*Structure*:

* seats in the parliament are hard coded
* agent type is `Negotiator`
* `setup_negotiators` function is used to create the global agent list
* `get_party_opinions` is used to extract party opinion vectors from the wahlomat data
* `get_party_combinations` function creates an iterators over all n-combinations of parties
* `meta_run!` creates an ABM in each step, with the agents from the involved parties, one model run is one step
* `negotiation!` is what happens in a step: participants of specified fractions meet and mingle according to the modified Axelrod model
* `populate!` fills the model for a step with agents
* `agent_step!` is a dummy function to satisfy the Agents.jl requirements
* `model_step!` is where the magic happens
* `assimilate!` is the Axelrod function (modified though)
* `similarity` computes the similarity between two agents (or two opinion vectors)
* `can_form_government` tests if involved parties can form a goverment (enough seats and sufficient consensus)
* `party_consensus` returns the consensus opinions in one party


*Procedure*:

* create a vector with the party names to include in the negotiations
* read the data from wahlomat
* call `setup_negotiators` to create the global agent list
* draw a sequence of negotiation combinations
* call `meta_run!` to run the model with the drawn sequence
