! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators hashtables kernel make math
namespaces sequences sequences.deep strings supercollider.server
supercollider.syntax supercollider.utility ;
IN: supercollider.node

TUPLE: node
    { name string }
    { id integer }
    { position integer } ! FIX: ensure this is only one of the add-actions
    { target integer }
    { controls array }
    ! body
    { server sc-server }
    { metadata hashtable } ;

: <node> ( name id position target controls -- node )
    node new
    sc-server get >>server
    swap >>controls
    swap >>target
    swap >>position
    swap >>id
    swap >>name ;

GENERIC: node-id ( node-or-id -- id ) ! Get the ID of a node object. If an integer is provided, simply return it as is.

M: node node-id
    id>> ;

M: integer node-id ;

SC: sc-server-free-node ( sc-server nodes -- )
ensure-array [ node-id ] map "/n_free" swap (msg-sc-server) ;

: free-node ( node -- ) ! Free a node or nodes on the server.
    sc-free-node ;

! FIX: allow setting multiple nodes at once
SC: sc-server-run-node ( sc-server node ? -- )
[ node-id ] [ boolean>number ] bi* 2array "/n_run" swap (msg-sc-server) ;

! FIX: allow setting multiple nodes at once
SC: sc-server-control-node ( sc-server node params-and-values -- )
[ node-id ] dip flatten append "/n_set" swap (msg-sc-server) ;

! FIX: allow setting multiple values at once
: control-node ( node param value -- ) ! Set the value of one of a `node`'s controls.
    2array sc-control-node ;

! FIX: allow setting multiple param ranges at once
SC: sc-server-control-n-node ( sc-server node start-param values -- )
[ node-id ] 2dip dup length swap [ 3array ] dip append "/n_setn" swap (msg-sc-server) ;

! FIX: allow setting multiple param ranges at once
SC: sc-server-fill-node ( sc-server node start-param value -- )
[ node-id ] 2dip dup length swap [ 3array ] dip append "/n_fill" swap (msg-sc-server) ;

! FIX: allow setting multiple param ranges at once
! FIX: use `bus-id` to get the bus id
SC: sc-server-map-node ( sc-server node param bus -- ) ! Map PARAM of NODE to BUS.
[ node-id ] 2dip 3array "/n_map" swap (msg-sc-server) ;

! FIX: allow setting multiple param ranges at once
! FIX: use `bus-id` to get the bus id
SC: sc-server-map-n-node ( sc-server node start-param num-params start-bus -- )
[ node-id ] 3dip 4array "/n_mapn" swap (msg-sc-server) ;

! FIX: allow setting multiple param ranges at once
! FIX: use `bus-id` to get the bus id
SC: sc-server-map-audio-node ( sc-server node param bus -- ) ! Map PARAM of NODE to an audio bus.
[ node-id ] 2dip 3array "/n_mapa" swap (msg-sc-server) ;

! FIX: allow setting multiple param ranges at once
! FIX: use `bus-id` to get the bus id
SC: sc-server-map-audio-n-node ( sc-server node start-param num-params start-bus -- )
[ node-id ] 3dip 4array "/n_mapan" swap (msg-sc-server) ;

! FIX: allow setting multiple nodes
SC: sc-server-before-node ( sc-server node before-node -- ) ! Move NODE before BEFORE-NODE.
[ node-id ] bi@ 2array "/n_before" swap (msg-sc-server) ;

! FIX: allow setting multiple nodes
SC: sc-server-after-node ( sc-server node after-node -- ) ! Move NODE after AFTER-NODE.
[ node-id ] bi@ 2array "/n_after" swap (msg-sc-server) ;

! FIX: get all of the /n_info responses
SC: sc-server-query-node ( sc-server nodes -- )
ensure-array [ node-id ] map "/n_query" swap (msg-sc-server) ;

SC: sc-server-trace-node ( sc-server nodes -- )
ensure-array [ node-id ] map "/n_trace" swap (msg-sc-server) ;

SC: sc-server-order-node ( sc-server nodes target-node position -- )
{ [ ensure-array [ node-id ] map ]
  [ node-id 1array ]
  [ 1array ] } spread prepend prepend "/n_order" swap (msg-sc-server) ;

SC: sc-server-play-synth ( sc-server synth id position target params -- ) ! Start a synth on the server. See also: `play-synth`, `launch-synth`, `play`.
[ 4array ] dip append "/s_new" (msg-sc-server) ;

: play-node ( node -- ) ! Play a synth on the server from a `node` object. Generally you should use `play-synth`, `launch-synth`, or `play` instead of calling this directly.
    { [ name>> ] [ id>> ] [ position>> ] [ target>> ] [ controls>> ] } cleave sc-play-synth ;

! FIX: check that the response is /n_set
SC: sc-server-get-synth-controls ( sc-server node controls -- values )
ensure-array [ node-id 1array ] dip append "/s_get" swap msg-sc-server nip ;

! FIX: allow getting multiple ranges
! FIX: check that the response is /n_setn
SC: sc-server-get-n-synth-controls ( sc-server node start-control num-controls -- values )
[ node-id ] 2dip 3array "/s_getn" swap msg-sc-server nip ;

SC: sc-server-unassign-synth-id ( sc-server nodes -- )
ensure-array [ node-id ] map "/s_noid" swap (msg-sc-server) ;
