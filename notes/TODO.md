# Notes

## Short-term

    * vote on coalition contract (eval: who could reach how many of their goals?)
    * relative position in negotiations -> correlation with coalition "success"

    * stop criterium (what's a viable coalition?)
    * likelihood estimation
    * [opinion](opinion) weighting -> incl. how to compute (e.g. similarity?)

    -> apply to future elections

## Long-term

    * we need to define utility / payoff
        * distance between coalition opinion and initial party opinion (or initial individual opinion)
    * opinion variability within group  // DISCUSS -> probably later
    * aim at minimal coalition
        * seats in Bundestag as "currency"
    * add stubbornness (only move by one in every dimension) [COMMENT 2022-02-09: kind of included now, needs further cosideration]



## Convergence

### IDEA 1:

    * start counter for how many times there was no assimilate!
    * if some_number > counter -> break

### IDEA 2:

    * 1s and 0s into array -> running mean
    * if running mean < some_number -> break

### IDEA 3: DOESN'T WORK!

    * Compare hashes of two states as convergence?
    * If same: increase counter
    * Else: counter = 0
    * If counter > k: break
    * ?hash -> for hashing
    * dispatch multiple hash functions for each type
    * summarize in "deephash"


# TODO:

* [x] create new test database for testing
* [x] finish new config procedure
* [x] finish new model setup
* [x] update tests to new workflow
* [x] streamline up to model runs
* [ ] refactor conforms_to_schema function
* [ ] weights for opinions


# MAYBE TODO:
* [ ] reward function (how close is the final consensus to the initial opinion?)
* [ ] interactive "walkthrough" create_params function
