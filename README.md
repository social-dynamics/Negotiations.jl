# Party Negotiations

*An agent-based model of post-election negotiations about government formation between parties elected for parliament.*

## How to use the module

First of all, you need to create a suitable dataset with a "Wahlomat" dataset.
The [*Wahlomat*](https://www.bpb.de/politik/wahlen/wahl-o-mat/) is a service that is provided by the German *Bundeszentrale für Politische Bildung* (BPB) for citizens to assess which party they are most in agreement with.
The data to compare one's opinions to are surveyed from all parties that participate in the election in question.
We treat these answers as opinion vectors.
This module is an implementation of an agent-based model that simulates negotiations between parties after an election.

Some more information is required to setup the model properly (see `test/test-config.yaml`, a yaml file with the same structure needs to be supplied to run the model).
Other than that, the `simulate` function requires a database with a specific schema.
You can create this database using the `initialize_db` function.
The data processing is still in user land though because the data provided by BPB is not standardized across different datasets.
Once you have created the required database and yaml file, you can run the model like this:

```{julia}
using Negotiations
params = parameter_set_from_config("config.yaml")
db = load_database("db.sqlite")
model = setup_model(params, db)
simulate(model, 5, db, batchname = "my_batchname")
```


## How the model works (WIP)

At this stage, this model is highly speculative and should not be taken at face value.
We seek to find a way to think about the negotiation process in a multi-party political system by integrating opinion dynamics models with a model of sequential party negotiations.
The opinion dynamics model used in this model might become a "pluggable" component of the model, i.e., different models of opinion exchange could be tested in this framework.
For the current implementation, we make several simplifying assumptions:

    * The *Wahlomat* data is a sufficiently accurate and representative depiction of the political issues that are to be negotiated.
    * The formation of a government in a democratic multi-party political system is preceded by a series of negotiations between different parties.
    * More information specific to an election at hand can be included in the model (for instance, in the German federal elections, most parties give statements which other parties they are willing to negotiate with).


## Important factors that are still missing (WIP)

*Game-theoretical considerations*:

    * Number of seats in the parliament is a crucial factor in negotiations as it partly determines the strength of a party's position. However, a small party with few seats might have a strong position as well if it could, for instance, side with either of two larger parties and thus determine the result of the negotiations.

*A more diverse range of opinion dynamics models*:

    * A the moment, we employ a simple opinion dynamics model based on the principle of homophily. There are many other plausible models for the situation at hand. As mentioned above, these could be added as "plug-and-play" components to the module.
