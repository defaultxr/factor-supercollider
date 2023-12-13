! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.short-circuit
concurrency.conditions continuations init io.files.temp io.launcher
kernel math namespaces ranges sequences strings supercollider.env
supercollider.node supercollider.server supercollider.spec
supercollider.syntax supercollider.synthdef supercollider.ugen
supercollider.utility threads ;
IN: supercollider

! add actions

CONSTANT: +head+ 0
CONSTANT: +tail+ 1
CONSTANT: +before+ 2
CONSTANT: +after+ 3
CONSTANT: +replace+ 4

: add-action? ( object -- ? )
    +head+ +replace+ [a..b] member? ;

! synth

:: synth-spec>node ( synth-spec -- node ) ! Convert a synth-spec into a `node` object.
    synth-spec length even? [ "a synth-spec must consist of the synthdef name and alternating keys and values" throw ] when
    synth-spec first :> name
    synth-spec 1 tail :> controls
    sc-get-next-node-id :> id
    +head+ :> position
    { [ "group" controls plist-at ]
      [ 1 ]
    } 0|| :> target
    name id position target controls <node> ;

: play-synth ( synth-spec -- node ) ! Play a synth on the server and return a node object representing it.
    synth-spec>node [ play-node ] keep ;

! FIX: Should this return a `node` with an ID of -1? We would have to handle the case of node objects with -1 IDs in `free-node` and the like.
: launch-synth ( synth-spec -- ) ! Play a synth on the server without allocating it an ID. This should generally only be used for synths that will free themselves when finished, i.e. "one-shots". For synths that sustain, see `play-synth` instead, which will return a synth object that contains its ID, allowing you to control it.
    [ first 1array { -1 0 1 } ]
    [ rest ] bi 3append
    "/s_new" swap (msg-sc) ;

GENERIC: synth ( synth-spec -- node )

M: array synth
    play-synth ;

M: string synth
    1array play-synth ;

! general generics

GENERIC: play ( object -- object' )

M: array play
    synth ;

GENERIC: stop ( object -- )

M: node stop
    free-node ;

M: array stop
    free-node ;

GENERIC: launch ( object -- object' )

GENERIC: end ( object -- )

M: node end
    "gate" 0 control-node ;

GENERIC: render ( object -- object' )

! testing

: test-synth ( -- node )
    { "default" } synth ;
