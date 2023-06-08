! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators hashtables kernel make math
namespaces sequences strings supercollider.server
supercollider.utility ;
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

: play-node ( node -- ) ! Play a synth on the server from a `node` object. Generally you should use `play-synth`, `launch-synth`, or `play` instead of calling this directly.
    [ { [ name>> , ]
        [ id>> , ]
        [ position>> , ]
        [ target>> , ]
        [ controls>> % ] } cleave ]
    { } make "/s_new" swap (msg-sc) ;

: free-node ( node -- ) ! Free a node or nodes on the server.
    ensure-array [ node-id ] map "/n_free" swap (msg-sc) ;

: control-node ( node param value -- ) ! Set the value of one of a `node`'s controls.
    2array [ node-id 1array ] dip append "/n_set" swap (msg-sc) ;
