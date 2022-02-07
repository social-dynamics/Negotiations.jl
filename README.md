# Party Negotiations

*An agent-based model of post-election negotiations about government formation between parties elected for parliament.*

## How to use

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
