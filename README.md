# Party Negotiations

This is a model of the German coalition negotiations to form a government.


## How to use

First of all, you need to create a suitable dataset with a "Wahlomat" dataset.
The [*Wahlomat*](https://www.bpb.de/politik/wahlen/wahl-o-mat/) is a service that is provided by the German *Bundeszentrale für Politische Bildung* for citizens to assess which party they are most in agreement with.
The data to compare one's opinions to are surveyed from all parties that participate in the election in question.
We treat these answers as opinion vectors.
This module is an implementation of an agent-based model that simulates negotiations between parties after an election.

Some more information is required to setup the model properly (see `test/test-config.yaml`, a yaml file with the same structure needs to be supplied to run the model).

Once you have obtained the Wahlomat data and stored it in a database (TODO: document how the database needs to look like) and created a `config.yaml` file with the required structure (TODO: document this as well), you can run the model as follows (in this example with `5` replicates):

```{julia}
using Negotiators
params = parameter_set_from_config("config.yaml")
db = load_database("db.sqlite")
model = setup_model(params, db)
simulate(model, 5, db)
```
