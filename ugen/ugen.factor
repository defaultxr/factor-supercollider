! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays classes.tuple combinators kernel lexer
locals.types math math.order parser prettyprint sequences
strings supercollider.node supercollider.server
supercollider.syntax supercollider.utility words.symbol ;
IN: supercollider.ugen

SYMBOLS: ar kr ir dr pure ;

TUPLE: control
    { name string }
    { initial-value float } ;

! inputs was going to be an alist mapping input names to default values?
TUPLE: ugen
    { name string }
    { rate symbol initial: ar }
    { inputs array } ! array of control-spec objects
    { outputs array } ;

UNION: ugen-input number ugen ;

TUPLE: control-spec
    { name string }
    { default ugen-input }
    spec ;

! pseugen: pseudo-ugen; a ugen graph that can be embedded in another ugen graph as if it were a regular ugen.
TUPLE: pseugen < ugen
    { body quote } ;

: check-input-array-length ( input -- )
    dup length 1 3 between?
    [ unparse "incorrect number of arguments for input: " prepend throw ] unless
    drop ;

! : check-input-array ( input -- input ) ! FIX
!     ;

: check-control-spec-name ( obj -- obj )
    ;

: check-control-spec-default ( obj -- obj )
    ;

: check-control-spec-spec ( obj -- obj )
    ;

: ensure-input-spec-array ( input -- array )
    ensure-array
    [ check-input-array-length ] keep
    [ 0 swap ?nth check-control-spec-name ]
    [ 1 swap ?nth 0 or check-control-spec-default ]
    [ 2 swap ?nth f or check-control-spec-spec ]
    tri 3array ;

: array>control-spec ( array -- control-spec )
    control-spec slots>tuple ;

: <control-spec> ( input -- control-spec )
    ensure-input-spec-array array>control-spec ;

: parse-synth-input-tokens ( end -- tokens )
    parse-tokens ;

: parse-synth-output-tokens ( end -- tokens )
    parse-tokens ;

: parse-synth-effect ( end -- inputs outputs )
    [ "--" parse-synth-input-tokens ] dip
    parse-synth-output-tokens ;

: scan-synth-effect ( -- inputs outputs )
    "(" expect ")" parse-synth-effect ;

: scan-synth-attributes ( -- attributes )
    scan-object ensure-array ;

: parse-ugen-definition ( -- attributes inputs outputs )
    scan-token {
        { "<" [ scan-synth-attributes scan-synth-effect ] }
        [ drop { ar kr } ")" parse-synth-effect ]
    } case ;

: (UGEN:) ( -- name attributes inputs outputs )
    scan-word-name scan-object scan-synth-effect ;

SYNTAX: UGEN: (UGEN:) 4array suffix! ;

SC: sc-server-ugen-command ( sc-server node ugen-index command args -- )
[ node-id ] 3dip [ 3array ] dip append "/u_cmd" swap (msg-sc-server) ;
