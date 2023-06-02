# factor-supercollider

Early stages of a work-in-progress SuperCollider vocabulary for Factor.

Builds upon and requires the [OSC](https://github.com/defaultxr/factor-osc) vocabulary.

## Usage

Currently, there is not a lot of functionality implemented. But the following should work on Linux or Mac if you have SuperCollider installed in a standard location and this vocabulary in one of your Factor `vocab-roots`:

1. `USE: supercollider` to load the vocab. Note that you will need to have the Factor [OSC](https://github.com/defaultxr/factor-osc) vocab installed in your `vocab-roots`.

2. `start-sc` to start the SuperCollider server (`scsynth`) listening on port `57330`.

3. `"default" { "amp" 0.5 } synth` to start the synth named `default` with its `amp` parameter set to `0.5`. Note that you must already have a synth with that name defined and written as a `scsynthdef` file in SuperCollider's synthdefs directory. At the moment, this vocab does not support defining SynthDefs.

4. `1 group-query-tree.` to print a list of all nodes running on the server. If all has went well, you should see the `default` synth from step 3 active.

## Future

The following features are planned:

* Functionality to load and control synths, buffers, buses, groups, etc conveniently from Factor.
* `UGEN:` word to define ugens.
* Functionality to auto-generate ugen definitions by scraping from the local SuperCollider instance.
* `PSEUGEN:` word to define "pseudo-ugens".
* `SYNTH:` word to define synthdefs in Factor.
* Functionality to easily convert pseugens to synthdefs and vice-versa.
* `NODE:` to define named nodes on the server.
* Metadata about synthdef/ugen parameters, such as their expected input range and standard output range.
* Envelopes.
* Buffer management.
* Task scheduler and tempo clock.
* SuperCollider/[cl-patterns](https://github.com/defaultxr/cl-patterns)-esque patterns system (as a separate vocabulary).
* Documentation.
* Tests.
* And more!

## Bugs

No software would be complete without a few bugs. Here are the current known issues.

* `scsynth` output is sent to the listener window by following its output as it is sent to a file. This is needed as posting directly to the listener doesn't work. At the moment the output file is monitored and its last line read with `file-lines last`. This seems like it may be very inefficient, especially once the file reaches a large enough size. Instead it may be good to use `stream-seek` in combination with `seek-end`.
