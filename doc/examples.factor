! examples.factor
! This file simply contains examples of factor-supercollider usage.
! Though at the moment, it only contains synthdef examples.
! Additionally, none of these examples will work yet, as defining synths is not yet implemented.

! Very simple synthdef example:
SYNTH: simple ( -- output ) ! no inputs, one output
! it specifies the ugen's parameters, in order, which are: freq, phase, and mul.
! this synthdef creates a sine wave oscillator, sets its frequency to 440Hz, and sets its mul to 0.2, which lowers its volume such that its output ranges from -0.2 to 0.2.
    SinOsc.ar 440 >>freq 0.2 >>mul ;

! Another way of writing the same:
SYNTH: simple2 ( -- output )
! this time, we use >SinOsc.ar , which takes 1 item from the stack and uses it as the SinOsc's freq input.
! instead of lowering the volume with the SinOsc's mul slot, we instead just multiply its output by 0.2, which does the same thing.
    440 >SinOsc.ar 0.2 * ;

! In the following synthdef, we use the double-colon syntax so we can refer to inputs by name.
! We don't specify an Out.ar (or an "out" argument) and instead rely on SYNTH auto-inserting them for us.
! This also allows for multi-channel expansion, and makes it easier to use synthdefs as pseugens.
SYNTH:: default ( gate: 1 freq: 440 attack: 0.01 decay: 0.01 sustain: 1 release: 0.01 -- output )
    freq >SinOsc.ar 0.2 *
    attack decay sustain release >Env.adsr >EnvGen.kr gate >>gate +free+ >>doneAction
    * ;

! Here's another way of writing the above, using local variables:
SYNTH:: default ( gate: 1 freq: 440 attack: 0.01 decay: 0.01 sustain: 1 release: 0.01 -- output )
    freq >SinOsc.ar 0.2 * :> sinosc
    attack decay sustain release >Env.adsr >EnvGen.kr gate >>gate +free+ >>doneAction :> envgen
    ! we use Pan2 to turn a mono signal into a stereo signal, with the "pan" variable used to set the panning.
    ! "pan" is automatically added as an input parameter (defaulting to 0) if it is used in the body
    ! even if it is not explicitly listed in the synth's inputs.
    sinosc envgen * >Pan2.ar pan >>pan :> pan2
    ! we also explicitly provide Out.ar here.
    ! similar to the "pan" variable above, "out" is also automatically added when needed, and also defaults to 0.
    pan2 >Out.ar out >>out ;

! In this one, we use one-colon syntax for a more traditional Factor-style definition:
SYNTH: filtered-saw ( freq ffreq -- output )
    ! we take freq off the stack and use it as the sole input (the frequency) of the Saw.ar.
    ! if a ugen's input is not an array, it treats it as an array of 1 element.
    swap >Saw.ar
    ! then we take the Saw.ar and ffreq off the stack and use them as the inputs to LPF.ar.
    ! at the end, only the LPF is left on the stack. its output is used as the output of the filtered-saw synth.
    >LPF.ar swap >>ffreq ;

! Here's a simple example wrapping Pitch.kr to demonstrate multiple outputs.
! In most cases you can just use Pitch.kr directly and don't need to define a synth like this.
SYNTH: pitch-tracker ( input -- pitch has-freq? )
    ! Pitch.kr outputs two values: the detected pitch, and whether it is detecting a pitch currently.
    ! these two values are used as the pitch and has-freq? outputs.
    Pitch.kr ;

! Synthdefs can be used inside other synthdefs. Here's an example of that:
SYNTH: sound-in-sine ( -- output )
    ! SoundIn will by default read one channel from the first hardware input (usually your microphone).
    SoundIn.ar
    ! send it through our pitch-tracker synth defined above
    pitch-tracker
    ! drop the has-freq? output.
    drop
    ! play a sinewave at the frequency that pitch-tracker outputs.
    >SinOsc.ar 0.5 * ;
