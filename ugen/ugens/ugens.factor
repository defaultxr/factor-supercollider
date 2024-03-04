! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes.parser classes.tuple combinators
kernel lexer locals.types math math.order namespaces parser
prettyprint roles sequences strings supercollider.node
supercollider.server supercollider.spec supercollider.syntax
supercollider.ugen supercollider.utility words.symbol ;
IN: supercollider.ugen.ugens

ROLE-TUPLE: SinOsc <{ pure-ugen ar kr mul-add single-output }
    { freq initial: 440 }
    { phase initial: 0 } ;

! SinOsc { ar kr pure-ugen } set-attributes

SinOsc H{ { "freq" freq }
          { "phase" unipolar }
          { "output" bipolar } } set-specs

: SinOsc.ar ( -- sinosc )
    SinOsc new ar >>rate ;

: SinOsc.kr ( -- sinosc )
    SinOsc new kr >>rate ;

: >SinOsc.ar ( freq -- sinosc )
    SinOsc.ar swap >>freq ;

: >SinOsc.kr ( freq -- sinosc )
    SinOsc.kr swap >>freq ;

! this is what i'd like to be able to write instead:
! UGEN: SinOsc <{ pure-ugen ar kr mul-add single-output }
!     { freq freq initial: 440 }
!     { phase unipolar initial: 0 }
!     { output bipolar out } ;

ROLE-TUPLE: Out <{ ugen ar kr } ! does it have "output" in the same way SinOsc and similar ugens do?
    { bus initial: 0 }
    { input } ;

: Out.ar ( -- out )
    Out new ar >>rate ;

: Out.kr ( -- out )
    Out new kr >>rate ;

: >Out.ar ( input -- out )
    Out.ar swap >>input ;

: >Out.kr ( input -- out )
    Out.kr swap >>input ;
