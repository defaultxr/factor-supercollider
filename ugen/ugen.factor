! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.parser classes.tuple
classes.tuple.parser combinators hashtables kernel lexer
locals.types make math math.order namespaces parser prettyprint
roles sequences strings supercollider.node supercollider.server
supercollider.spec supercollider.syntax supercollider.utility
words.symbol ;
IN: supercollider.ugen

ROLE: ar ;
ROLE: kr ;
ROLE: ir ;
ROLE: dr ;

PREDICATE: rate < symbol { ar kr ir dr } member? ;

TUPLE: control
    { name string }
    { initial-value float } ;

TUPLE: ugen-definition
    { name string }
    { attributes sequence initial: { } }
    { supported-rates sequence initial: { ar } }
    { inputs sequence } ! array of control-spec objects
    { outputs sequence }
    { specs hashtable } ;

ROLE: ugen
    { rate rate initial: ar } ;

ROLE: pure-ugen < ugen ;

ROLE: mul-add
    { mul initial: 1 }
    { add initial: 0 } ;

DEFER: >>mul
DEFER: >>add

: madd ( ugen mul add -- ugen )
    [ >>mul ] [ >>add ] bi* ;

ROLE: single-output
    { output } ;

UNION: ugen-input number ugen ;

! ROLE: mul-add { mul initial: 1 } { add initial: 0 }

! pseugen: pseudo-ugen; a ugen graph that can be embedded in another ugen graph as if it were a regular ugen.
! i don't think this is ndeeded if synthdefs can be embedded.
ROLE: pseugen < ugen
    { body quote } ;

SYMBOL: ugens

ugens [
    H{ }
] initialize

SYMBOL: ugen-attributes
ugen-attributes [ H{ } ] initialize

: set-attributes ( ugen attributes -- )
    swap ugen-attributes get set-at ;

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

SYMBOLS: freq bipolar unipolar ;

SYMBOL: slot-types

slot-types [ { freq bipolar unipolar } ] initialize

: parse-ugen-long-slot ( -- slot-definition input-spec )
    "}" parse-tokens [ slot-types member? not ] partition ;

: parse-ugen-short-slot ( slot-name -- slot-definition input-spec )
    1array { } ;

: parse-ugen-slot ( lexer -- slot-definition input-spec )
    lexer:parse-token dup "{" =
                      [ drop parse-ugen-long-slot ]
                      [ parse-ugen-short-slot ] if ;


! : parse-slot-name-delim ( end-delim string/f -- ? )
!     {
!         {
!             [ dup { ":" "(" "<" "\"" "!" } member? ]
!             [ invalid-slot-name ]
!         }
!         { [ 2dup = ] [ drop f ] }
!         [ dup "{" = [ drop parse-long-slot-name ] when , t ]
!     } cond nip ;

: parse-ugen-slots-delim ( end-delim -- )
    dup scan-token parse-slot-name-delim
    [ parse-ugen-slots-delim ] [ drop ] if ;

: parse-ugen-slots ( -- slots specs ) ! FIX
    ";" parse-ugen-slots-delim 1 2 ;

: parse-ugen-attributes ( -- attributes )
    "}" parse-tokens ;

: parse-ugen-definition ( -- attributes slots specs )
    scan-token {
        { ";" [ { } { } { } ] }
        { "<" [ scan-word 1array parse-ugen-slots ] }
        { "<{" [ \ } parse-until >array parse-ugen-slots ] }
        [ drop { } parse-ugen-slots ]
    } case
    ! dup check-duplicate-slots 3dup check-slot-shadowing
    ;

: (UGEN:) ( -- name attributes slots specs )
    scan-new-class parse-ugen-definition
    ! scan-object suffix!
    ! \ ; parse-until suffix!
    ! parse-ugen-slots
    ;

: define-ugen ( name attributes slots specs -- )
    . . . . ;

SYNTAX: UGEN: ! returns: ugen-name ugen-types ugen-inputs input-specs
        (UGEN:) define-ugen
        ;

SC: sc-server-ugen-command ( sc-server node ugen-index command args -- )
[ node-id ] 3dip [ 3array ] dip append "/u_cmd" swap (msg-sc-server) ;

