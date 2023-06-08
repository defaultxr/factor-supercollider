! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays grouping io kernel math math.parser
namespaces prettyprint.sections sequences supercollider.node
supercollider.server supercollider.syntax supercollider.utility ;
IN: supercollider.group

TUPLE: group < node ;

: <group> ( id action target -- group )
    group new
    swap >>target
    swap >>action
    swap >>id ;

GENERIC: group-id ( group-or-id -- id ) ! Get the ID of a group object. If an integer is provided, simply return it as is.

M: group group-id
    id>> ;

M: integer group-id ;

SC: (sc-server-new-group) ( sc-server id add-action target-id msg -- )
[ 3array ] dip swap msg-sc-server 2drop ;

! : sc-server-new-group ( sc-server id add-action target-id -- ) ! Make a group on the server. See also: `sc-new-group`, `<group>`.
!     3array "/g_new" swap msg-sc-server 2drop ;

SC: sc-server-new-group ( sc-server id add-action target-id -- ) ! Make a group on the server. See also: `sc-new-group`, `<group>`.
"/g_new" (sc-server-new-group) ;

SC: sc-server-new-parallel-group ( sc-server id add-action target-id -- ) ! Make a group on the server. See also: `sc-new-group`, `<group>`.
"/p_new" (sc-server-new-group) ;

! : sc-new-group ( id add-action target-id -- )
!     sc-server get 4 -nrot sc-server-new-group ;

! SC: sc-server-new-parallel-group ( sc-server id add-action target-id -- ) ;

: group-dump-tree ( group print-control-values? -- )
    [ group-id ]
    [ boolean>number ] bi*
    2array "/g_dumpTree" swap (msg-sc) ;

: group-query-tree ( group -- seq )
    group-id 0 2array "/g_queryTree" swap msg-sc nip ;

: server-query-tree ( sc-server -- seq )
    [ 0 group-query-tree ] with-sc-server ;

: query-tree ( -- seq )
    sc-server get server-query-tree ;

: group-query-tree-node-id ( array -- node-id )
    first ;

: group-query-tree-node-children ( array -- children )
    second ;

: group-query-tree-node-synth? ( array -- synth? )
    group-query-tree-node-children -1 = ;

: group-query-tree-node-synth-name ( array -- synth-name/f )
    dup group-query-tree-node-synth? [ 2 swap nth ] [ drop f ] if ;

:: group-query-tree-node-num-controls-index ( has-controls? array -- controls-index/f )
    has-controls?
    [ array group-query-tree-node-synth? [ 2 ] [ 1 ] if
      has-controls? 1 0 ? + ]
    [ f ] if ;

:: group-query-tree-node-num-controls ( has-controls? array -- num-controls )
    has-controls? array group-query-tree-node-num-controls-index :> controls-index
    controls-index [ controls-index array nth ] [ 0 ] if ;

: group-query-tree-node-controls-end-index ( has-controls? array -- num-controls )
    [ group-query-tree-node-num-controls-index ]
    [ group-query-tree-node-num-controls 2 * ] 2bi + ;

:: group-query-tree-node-controls-array ( has-controls? array -- controls )
    has-controls? array
    [ group-query-tree-node-num-controls-index 1 + ]
    [ group-query-tree-node-controls-end-index 1 + ] 2bi
    array subseq ;

:: group-query-tree-node-rest ( has-controls? array -- controls )
    array has-controls? array group-query-tree-node-controls-end-index 1 + tail ;

: control-id-string ( x -- str ) ! Convert numbers to strings. Strings remain strings.
    dup number? [ number>string ] when ;

: group-query-tree-synth-control-pair. ( controls-array -- )
    [ first control-id-string write ": " write ]
    [ second control-id-string write "\n" write ] bi ;

: group-query-tree-synth-controls. ( has-controls? array -- )
    group-query-tree-node-controls-array 2 grouping:group
    <block
    [ group-query-tree-synth-control-pair. ] each
    block> ;

DEFER: group-query-tree-node.

:: group-query-tree-synth. ( has-controls? array -- rest )
    <block
    "S " write
    array group-query-tree-node-id number>string write
    ": " write
    array group-query-tree-node-synth-name write
    has-controls? [
        ": " write
        has-controls? array group-query-tree-synth-controls. ] when
    block>
    array has-controls? array group-query-tree-node-controls-end-index tail ;

:: group-query-tree-group. ( has-controls? array -- rest )
    <block
    "G " write
    array group-query-tree-node-id number>string write
    ": " write
    has-controls? array 2 tail group-query-tree-node.
    block> { } ;

:: group-query-tree-node. ( has-controls? array -- )
    array group-query-tree-node-synth? :> synth?
    has-controls? array synth?
    [ group-query-tree-synth. ]
    [ group-query-tree-group. ] if
    has-controls? swap group-query-tree-node. ; recursive

: group-query-tree*. ( array -- )
    [ [ first number>boolean ]
      [ rest ] bi group-query-tree-node.
    ] with-pprint ;

: group-query-tree. ( group -- ) ! Pretty-print the node tree of GROUP.
    group-query-tree group-query-tree*. ;
