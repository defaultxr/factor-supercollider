! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays classes.tuple combinators
effects.parser endian io io.encodings.binary io.files
io.streams.string kernel lexer locals.types math math.order
namespaces pack parser prettyprint sequences strings
supercollider supercollider.config supercollider.utility
words.symbol ;
IN: supercollider.synthdef

! * 
! https://doc.sccode.org/Reference/Synth-Definition-File-Format.html

! SYNTH: defines a ugen graph, which can also be used as a synthdef.
! when the word defined by SYNTH: is called, it returns a ugen graph object.
! the ugen graph object can then be started with the "play" generic
! or its parameters can be set/changed first.
! the play generic will return a node object, which can also have its parameters changed.
! it's also possible to start a synth immediately with the "synth" word
! "synth" accepts the synth name and an assoc of its arguments.

SYMBOLS: ar kr ir dr ;

TUPLE: control
    { name string }
    { initial-value float } ;

! inputs was going to be an alist mapping input names to default values?
TUPLE: ugen
    { name string }
    { rate symbol initial: ar }
    { inputs array } ! array of ugen-input-spec objects
    { outputs array } ;

! pseugen: pseudo-ugen; a ugen graph that can be embedded in another ugen graph as if it were a regular ugen.
TUPLE: pseugen < ugen
    ! { name string }
    ! { inputs array } ! array of ugen-input-spec objects
    ! { outputs array }
    { body quote } ;

UNION: ugen-input number ugen ;

TUPLE: ugen-input-spec
    { name string }
    { default ugen-input }
    spec ;

: assert-ugen ( object -- object )
    [ ugen? [ "send-synthdef must be used on a ugen-like object" throw ] unless ] keep ; ! FIX: use assert for this?

: check-input-array-length ( input -- )
    dup length 1 3 between?
    [ unparse "incorrect number of arguments for input: " swap append throw ] unless
    drop ;

! : check-input-array ( input -- input ) ! FIX
!     ;

: check-ugen-input-spec-name ( obj -- obj )
    ;

: check-ugen-input-spec-default ( obj -- obj )
    ;

: check-ugen-input-spec-spec ( obj -- obj )
    ;

: ensure-input-spec-array ( input -- array )
    ensure-array
    [ check-input-array-length ] keep
    [ 0 swap ?nth check-ugen-input-spec-name ]
    [ 1 swap ?nth 0 or check-ugen-input-spec-default ]
    [ 2 swap ?nth f or check-ugen-input-spec-spec ]
    tri 3array ;

: array>ugen-input-spec ( array -- ugen-input-spec )
    ugen-input-spec slots>tuple ;

: <ugen-input-spec> ( input -- ugen-input-spec )
    ensure-input-spec-array array>ugen-input-spec ;

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

! (defugen (sin-osc "SinOsc")
!     (&optional (freq 440.0) (phase 0.0) (mul 1.0) (add 0.0))
!   ((:ar (madd (multinew new 'pure-ugen freq phase) mul add))
!    (:kr (madd (multinew new 'pure-ugen freq phase) mul add))))

: (UGEN:) ( -- name attributes inputs outputs )
    scan-word-name parse-ugen-definition ;

SYNTAX: UGEN: (UGEN:) 4array suffix! ;

SYNTAX: FOO: scan-synth-effect 2array suffix! ;

! UGEN: SinOsc < { pure rates: { ar kr } } ( ( freq 440 ) ( phase 0 ) ( mul 1 ) ( add 0 ) -- ( out 0 bipolar ) )
! { pure ar kr } ;

! ! can specify the rate in the ugen name:
! UGEN: Foo.ar < pure ( ( freq 440 ) ( phase 0 ) ( mul 1 ) ( add 0 ) -- ( out 0 bipolar ) )

! ! can specify the rate in the ugen name:
! UGEN: Foo.ar < { pure } ( ( freq 440 ) ( phase 0 ) ( mul 1 ) ( add 0 ) -- ( out 0 bipolar ) )
!     { pure } ;

! UGEN: SinOsc ( freq phase mul add -- out )
!     { freq 440 } ;

: parse-ugen ( name -- name rate )
    "foo" ;

! synthdef

TUPLE: synthdef < node
    ;

GENERIC: synthdef-file-path ( def -- path )

M: string synthdef-file-path
    sc-data-directory get "/synthdefs/" append
    swap ".scsyndef" 3append ;

M: synthdef synthdef-file-path
    name>> synthdef-file-path ;

CONSTANT: +type-id+ "SCgf"

: pstring ( str -- byte-array )
    [ length 1array ]
    [ >array ] bi
    append >byte-array ;

: int8 ( int -- byte-array )
    big-endian [ s8>byte-array ] with-endianness
    ! 1array >byte-array
    ;

: int16 ( int -- byte-array )
    big-endian [ s16>byte-array ] with-endianness ;

: int32 ( int -- byte-array )
    big-endian [ s32>byte-array ] with-endianness
    ! 1array "i" pack-be
    ;

: float32 ( float -- byte-array )
    write-float
    ! big-endian [ s32>byte-array ] with-endianness
    ! 1array "f" pack-be
    ;

: encoded-synthdef-type-id ( def -- byte-array )
    drop +type-id+ >byte-array ;

: encoded-synthdef-version-number ( def -- byte-array )
    drop B{ 0 0 0 2 }
    ! { 2 } "i" pack-be ! also works
    ;

: encoded-synthdef-number-of-synthdefs ( def -- byte-array )
    drop B{ 0 1 } ;

: encoded-synthdef-name ( def -- byte-array )
    name>> pstring ;

: synthdef-constants ( def -- array )
    drop { 0.0 } ;

: encoded-synthdef-constants ( def -- byte-array )
    synthdef-constants
    [ length int32 ]
    [ [ float32 ] map B{ } [ append ] reduce ] bi ! 1array "f" pack-be ! write-float
    append ;

: synthdef-controls ( def -- array )
    controls>> ;

! : control-initial-value ( control -- initial-value )
!     ;

: encoded-synthdef-controls ( def -- byte-array )
    synthdef-controls
    [ length int32 ]
    [ [ initial-value>> float32 ] map B{ } [ append ] reduce ] bi
    append ;

: encoded-synthdef-control-names ( def -- byte-array )
    synthdef-controls
    [ length int32 ]
    [ [ swap name>> pstring swap int32 append ] map-index B{ } [ append ] reduce ] bi
    append ;

: encoded-synthdef-ugen ( ugen index -- byte-array )
    swap
    { [ name>> pstring ]
      [ rate>> int8 ]
      [ inputs>> int32 ]
      [ outputs>> int32 ] } cleave 4array
    index int16
    ! encoded-synthdef-ugen-input-specs
    ! encoded-synthdef-ugen-output-specs
    ;

: synthdef-ugens ( def -- ugens )
    body>> ;

: encoded-synthdef-ugens ( def -- byte-array )
    synthdef-ugens
    [ length int32 ]
    [ [ swap name>> pstring swap int32 append ] map-index B{ } [ append ] reduce ] bi
    append ;

: encoded-synthdef-variants ( def -- byte-array )
    ! synthdef-variants
    ! [ length int32 ]
    ! [ [ swap name>> pstring swap int32 append ] map-index B{ } [ append ] reduce ] bi
    ! append
    drop B{ }
    ;

: write-synthdef-bytecode ( def -- )
    { [ encoded-synthdef-type-id write ]
      [ encoded-synthdef-version-number write ]
      [ encoded-synthdef-number-of-synthdefs write ]
      [ encoded-synthdef-name write ]
      [ encoded-synthdef-constants write ]
      [ encoded-synthdef-controls write ]
      [ encoded-synthdef-control-names write ]
      [ encoded-synthdef-ugens write ]
      [ encoded-synthdef-variants write ]
    } cleave ;

! [ write 0 ] map drop
! map reduce
! cleave [ write ] 4 napply

: synthdef-bytecode ( def -- byte-array )
    [ write-synthdef-bytecode ] with-string-writer ;

: write-synthdef-file ( def -- file )
    [ dup synthdef-file-path
      binary [ write-synthdef-bytecode ] with-file-writer ]
    [ synthdef-file-path ] bi ;

: send-synthdef ( def -- )
    assert-ugen drop ;

: (SYNTH:) ( -- word inputs outputs body )
    [ scan-word-name scan-synth-effect parse-definition ]
    with-definition ;

SYNTAX: SYNTH: (SYNTH:) 4array suffix! ;

! test functionality

: test-ugen ( -- ugen )
    ugen new
    "SinOsc" >>name
    ar >>rate
    { } >>inputs
    { } >>outputs
    ;

: test-synthdef ( -- def )
    synthdef new
    3 >>id
    "fafoo" >>name
    "freq" 440 control boa
    "out" 0 control boa
    2array >>controls ;

: test-write-synthdef ( -- )
    test-synthdef write-synthdef-file . ;
