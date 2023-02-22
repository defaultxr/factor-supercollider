# factor-supercollider

Very early stages of a work-in-progress SuperCollider vocabulary for Factor.

Builds upon and requires the [OSC](https://github.com/defaultxr/factor-osc) vocabulary.

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
  * And more!
