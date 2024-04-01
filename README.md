# factor-supercollider

Early stages of a work-in-progress SuperCollider vocabulary for Factor.

Builds upon and requires the [OSC](https://github.com/defaultxr/factor-osc) vocabulary.

## Start

Currently, there is not a lot of functionality implemented. But the following should work on Linux or Mac if you have SuperCollider installed in a standard location and this vocabulary in one of your Factor `vocab-roots`:

1. `USE: supercollider` to load the vocab. Note that you will also need to have the Factor [OSC](https://github.com/defaultxr/factor-osc) vocab installed in your `vocab-roots`.

2. `start-sc` to start the SuperCollider server (`scsynth`) listening on port `57330`.

3. `{ "default" "amp" 0.5 } synth` to start the synth named `default` with its `amp` parameter set to `0.5`. Note that you must already have a synth with that name defined and written as a `scsynthdef` file in SuperCollider's synthdefs directory (`sc-synthdef-directory` is the variable containing the directory factor-supercollider will look for synthdef files). At the moment, this vocab does not support defining SynthDefs.

4. `0 dump-group-tree` to print a list of all nodes running on the server. If all has went well, you should see the `default` synth from step 3 active. If your `default` synth also generates sound and `scsynth` is connected to your speakers, you should also hear it.

## Usage

See [doc/commands.md](doc/commands.md) for a listing of all SuperCollider OSC commands and their equivalent factor-supercollider words.

Note that each word with a name containing `sc-server` requires a `sc-server` object as an input. Each such word also has an equivalent with the same name sans `-server`, which doesn't require the `sc-server` object as an input, instead using the server bound to the `sc-server` variable. For example, `quit-sc-server` requires an `sc-server`, but `quit-sc` does not.

## Future

See [TODO.org](doc/TODO.org) for a list of planned features.

## Bugs

No software would be complete without a few bugs. Here are the current known issues.

* `scsynth` output is sent to the listener window by following its output as it is sent to a file. This is needed as posting directly to the listener doesn't work. At the moment the output file is monitored and its last line read with `file-lines last`. This seems like it may be very inefficient, especially once the file reaches a large enough size. Instead it may be good to use `stream-seek` in combination with `seek-end`.
