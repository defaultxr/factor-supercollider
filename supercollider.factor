! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel combinators combinators.short-circuit math math.order math.parser namespaces
words.symbol locals.types accessors classes.tuple effects effects.parser
parser lexer
sequences arrays byte-arrays strings splitting ranges
make prettyprint calendar
endian pack
init memory
continuations threads concurrency.conditions concurrency.mailboxes
io io.backend io.backend.unix io.timeouts
io.streams.string io.encodings.binary io.encodings.utf8
io.launcher io.pathnames io.files io.files.temp io.sockets io.monitors
ui.tools.listener
system xdg
osc
supercollider.utility supercollider.config supercollider.server supercollider.syntax ;
IN: supercollider

! server commands/control

SC: start-sc-server ( sc-server -- )
[ dup [ scsynth-arguments ]
  [ stdout>> ] bi
  <process>
  swap >>stdout
  swap >>command
  "supercollider-stderr.txt" temp-file >>stderr
  run-detached >>process drop ]
[ connect-sc-server ] bi ;

! : start-sc ( -- )
!     sc-server get start-sc-server ;

: quit-sc-server ( sc-server -- )
    "/quit" { } msg-sc-server 2drop ;

: quit-sc ( -- )
    sc-server get quit-sc-server ;

: kill-sc-server ( sc-server -- )
    process>> kill-process ;

: kill-sc ( -- )
    sc-server get kill-sc-server ;

: stop-sc-server ( sc-server -- )
    { [ [ quit-sc-server t ] curry [ timed-out-error? ] ignore-error/f ]
      [ kill-sc-server t ] } 1|| drop ;

: stop-sc ( -- )
    sc-server get stop-sc-server ;

: stop-all-sc-servers ( -- )
    sc-servers [ stop-sc-server ] each ;

[ stop-all-sc-servers ] "stop supercollider" add-shutdown-hook

! add actions

CONSTANT: +head+ 0
CONSTANT: +tail+ 1
CONSTANT: +before+ 2
CONSTANT: +after+ 3

: add-action? ( object -- ? )
    +head+ +after+ [a..b] member? ;

! node

TUPLE: node
    server
    id
    position
    target
    name
    ! controls
    ! body
    metadata ;

! synth

: launch-synth ( synth-spec -- ) ! Play a synth on the server without allocating it an ID. This should generally only be used for synths that will free themselves when finished, i.e. "one-shots". For synths that sustain, see `synth` instead, which will return a synth object that contains its ID, allowing you to control it.
    [ first 1array { -1 0 1 } ]
    [ rest ] bi 3append
    "/s_new" swap
    msg-sc 2drop ;

GENERIC: synth ( synth-spec -- node )

M: array synth
    launch-synth 1 ; ! FIX

M: string synth
    1array synth ;

! group

TUPLE: group < node
    ;

: <group> ( id action target -- group )
    group new
    swap >>target
    swap >>action
    swap >>id ;

GENERIC: group-id ( group-or-id -- id )

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

:: group-query-tree-child. ( flag array -- )
    <block
    array second :> children
    children -1 = [ "S " ] [ "G " ] if write
    array first number>string write
    ": " write
    block>
    ;

: group-query-tree. ( group -- ) ! Pretty-print the node tree of GROUP.
    group-query-tree 1 cut [ group-query-tree-child. ] with-pprint ;

! general generics

GENERIC: play ( object -- object' )

GENERIC: stop ( object -- object' )

GENERIC: launch ( object -- object' )

GENERIC: end ( object -- object' )

GENERIC: render ( object -- object' )

! testing

: test-synth ( -- )
    "/s_new" { "down" -1 0 0 } (msg-sc) ;
