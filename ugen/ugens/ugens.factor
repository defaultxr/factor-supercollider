! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays classes.parser classes.tuple combinators kernel
lexer locals.types math math.order namespaces parser prettyprint
sequences strings supercollider.node supercollider.server
supercollider.syntax supercollider.ugen supercollider.utility
words.symbol ;
IN: supercollider.ugen.ugens

! ugen definition example.
!
! ugen definitions have the following components:
! 1. the name of the ugen.
! 2. one or more symbols representing "metadata" about the ugen:
! - ar, kr, ir, dr - the ugen supports audio, control, initial, and/or demand rates, respectively.
! - pure - the ugen is "pure" (side effect-free).
! 3. a stack effect naming the inputs and outputs and metadata about each.
! if the input or output has a colon following it, it can be followed by a spec and/or an initial value.
!
! for example, for ( freq: freq 440 phase: 0 -- output: bipolar ) :
! the ugen accepts freq and phase arguments, which default to 440 and 0, respectively.
! the freq argument also supplies "freq" as the name of its control-spec.
! the ugen has one output, which is specified as being bipolar (i.e. normally ranges from -1 to 1).

! (defugen (sin-osc "SinOsc")
!     (&optional (freq 440.0) (phase 0.0) (mul 1.0) (add 0.0))
!   ((:ar (madd (multinew new 'pure-ugen freq phase) mul add))
!    (:kr (madd (multinew new 'pure-ugen freq phase) mul add))))

! this works
! UGEN: SinOsc { ar kr pure } ( freq: 440 phase: 0 mul: 1 add: 0 -- output: bipolar )

! "old" style follows:

! ! UGEN: SinOsc < { pure rates: { ar kr } } ( ( freq 440 ) ( phase 0 ) ( mul 1 ) ( add 0 ) -- ( out 0 bipolar ) )

! ! can specify the rate in the ugen name:
! UGEN: Foo.ar < pure ( ( freq 440 ) ( phase 0 ) ( mul 1 ) ( add 0 ) -- ( out 0 bipolar ) )

! ! can specify the rate in the ugen name:
! UGEN: Foo.ar < { pure } ( ( freq 440 ) ( phase 0 ) ( mul 1 ) ( add 0 ) -- ( out 0 bipolar ) )
!     { pure } ;

! UGEN: SinOsc ( freq phase mul add -- out )
!     { freq 440 } ;

