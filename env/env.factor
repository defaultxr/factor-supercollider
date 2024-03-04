! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences supercollider.utility ;
IN: supercollider.env

SINGLETONS: step linear exponential sine welch squared cubed hold ;

ALIAS: lin linear
ALIAS: exp exponential
ALIAS: wel welch
ALIAS: sqr squared
ALIAS: cub cubed

UNION: env-shape step linear exponential sine welch squared cubed hold ;

CONSTANT: env-shapes { { 0 step }
                       { 1 linear }
                       { 2 exponential }
                       { 3 sine }
                       { 4 welch }
                       { 5 squared }
                       { 6 cubed }
                       { 7 hold } }

: find-env-shape ( input -- seq/f )
    env-shapes case-any ;

: >env-shape ( input -- shape/f )
    find-env-shape [ last ] [ f ] if* ;

ALIAS: integer>env-shape >env-shape

: env-shape>integer ( shape -- integer/f )
    find-env-shape [ first ] [ f ] if* ;

TUPLE: env
    { levels sequence }
    { times sequence }
    { curves sequence }
    { curve-amounts sequence }
    { release-node }
    { loop-node } ;

: <env> ( levels times -- env )
    env new swap >>times swap >>levels ;
