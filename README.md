# factor-supercollider

Very early stages of a work-in-progress SuperCollider vocabulary for Factor.

Builds upon and requires the [OSC](https://github.com/defaultxr/factor-osc) vocabulary.

The following features, among others, are planned:

  * Functionality to load and control synths, buffers, buses, groups, etc conveniently from Factor.
  * `UGEN:` word to define ugens.
  * Functionality to auto-generate ugen definitions by scraping from the local SuperCollider instance.
  * `SYNTH:` word to define synthdefs in Factor.
  * `PSEUGEN:` word to define "pseudo-ugens".
  * Functionality to easily convert pseugens to synthdefs and vice-versa.
  * Metadata about synthdef/ugen parameters, such as their expected input range and standard output range.
  * And more!
