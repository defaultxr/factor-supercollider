! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs combinators.short-circuit kernel math namespaces
sequences strings supercollider.utility ;
IN: supercollider.spec

SINGLETONS: linear exponential cosine decibel curve ;

ALIAS: lin linear
ALIAS: exp exponential
ALIAS: db decibel
ALIAS: cur curve

UNION: warp linear exponential cosine decibel curve ;

: >warp ( input -- warp )
    { { 0 linear }
      { exponential }
      { cosine }
      { decibel }
      { curve }
    } case-any [ last ] [ f ] if* ;

TUPLE: control-spec
    { name string }
    { min number }
    { max number }
    { warp warp initial: linear }
    { step number }
    { default number }
    { units string }
    grid ;

! MACRO: SPEC: ( -- )

SYMBOL: specs ! mapping spec names to their spec types
specs [ H{ } ] initialize

: set-spec ( spec-name spec-type -- )
    swap specs get set-at ;

SYMBOL: ugen-specs ! mapping ugens to input names to their spec types
ugen-specs [ H{ } ] initialize

: set-specs ( ugen specs -- )
    swap ugen-specs get set-at ;

: get-spec ( spec -- spec-type )
    specs get at ;

: get-ugen-spec ( ugen spec -- spec-type ) ! Get the spec-type for the specified UGEN and SPEC. Searches in ugen-specs first, and failing that, searches specs.
    { [ swap ugen-specs get at at ]
      [ nip specs get at ] } 2|| ;
