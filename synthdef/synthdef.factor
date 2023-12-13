! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays classes classes.parser
classes.tuple classes.tuple.parser combinators effects.parser
endian io io.encodings.binary io.files io.streams.string kernel
lexer locals.types make math math.order namespaces pack parser
prettyprint sequences strings supercollider supercollider.config
supercollider.node supercollider.server supercollider.syntax
supercollider.ugen supercollider.utility words.symbol ;
IN: supercollider.synthdef

! https://doc.sccode.org/Reference/Synth-Definition-File-Format.html

! SYNTH: defines a ugen graph, which can also be used as a synthdef.
! when the word defined by SYNTH: is called, it returns a synth (ugen graph) object.
! the synth object can then be started with the "play" generic, or its parameters can be set/changed first.
! alternatively, a synth object can be used inside another SYNTH definition.
! the play generic will return a `node`, which can also have its parameters changed (while it's running).
! it's also possible to start a synth immediately with the "synth" word
! "synth" accepts the synth name and an assoc of its arguments.

! Commands

! FIX: maybe auto-parse if a synthdef object or name is provided.
SC: sc-server-send-synthdef ( sc-server synthdef-bytecode -- )
byte-array check-instance
1array "/d_recv" swap msg-sc-server 2drop ;

SC: sc-server-load-synthdef ( sc-server path -- )
1array "/d_load" swap msg-sc-server 2drop ;

SC: sc-server-load-synthdef-directory ( sc-server path -- )
1array "/d_loadDir" swap msg-sc-server 2drop ;

SC: sc-server-free-synthdef ( sc-server synthdefs -- )
ensure-array "/d_free" swap (msg-sc-server) ;

! Defining synths in Factor

! a parsed synth definition.
! each ugen is an array naming the ugen and specifying its inputs.
! each ugen input is either a number (constant) or another ugen.
TUPLE: synthdef < pseugen
    { constants array }
    { ugens array }
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
    drop B{ 0 0 0 2 } ; ! { 2 } "i" pack-be ! also works

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
    inputs>> ;

! : control-initial-value ( control -- initial-value )
!     ;

: encoded-synthdef-controls ( def -- byte-array )
    synthdef-controls
    [ length int32 ]
    [ [ initial-value>> float32 ] map
      B{ } [ append ] reduce
    ] bi append ;

: encoded-synthdef-control-names ( def -- byte-array )
    synthdef-controls
    [ length int32 ]
    [ [ swap name>> pstring swap int32 append ] map-index
      B{ } [ append ] reduce
    ] bi append ;

: encoded-synthdef-ugen ( ugen index -- byte-array )
    swap
    { [ name>> pstring ]
      [ rate>> int8 ]
      [ inputs>> int32 ]
      [ outputs>> int32 ] } cleave 4array
    index int16
    ! encoded-synthdef-control-specs
    ! encoded-synthdef-ugen-output-specs
    ;

: synthdef-ugens ( def -- ugens )
    body>> ;

: encoded-synthdef-ugens ( def -- byte-array )
    synthdef-ugens
    [ length int32 ]
    [ [ swap name>> pstring swap int32 append ] map-index
      B{ } [ append ] reduce
    ] bi append ;

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
    ugen check-instance drop ;

: parse-synthdef-body ( def -- ) ! Parse the body of a `synthdef`, putting its constants and ugens into their slots.
    drop ! FIX
    ;

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
    "fafoo" >>name
    "freq" 440 control boa
    "out" 0 control boa
    2array >>inputs ;

: test-write-synthdef ( -- )
    test-synthdef write-synthdef-file . ;
