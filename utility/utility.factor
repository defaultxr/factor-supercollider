! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs grouping combinators.short-circuit
hashtables io io.encodings.utf8 io.files io.monitors kernel math
namespaces prettyprint sequences splitting system threads
ui.tools.listener ;
IN: supercollider.utility

! Booleans

: boolean>number ( boolean -- number )
    1 0 ? ;

: number>boolean ( boolean -- number )
    0 > ;

! Sequences

: case-any ( object sequence -- found ) ! Get the sequence that contains OBJECT.
    swap [ swap member? ] curry find nip ;

! Arrays

: ensure-array ( input -- array )
    dup array? [ 1array ] unless ;

! "Plists"/property lists, a la Common Lisp

: plist? ( object -- ? )
    { [ array? ]
      [ 0 swap ?nth array? not ]
      [ length even? ] } 1&& ;

: plist>hashtable ( plist -- hashtable )
    2 group >hashtable ;

: plist-at ( key plist -- value/f ) ! Get a value from a plist.
    2 <groups> at ;

! Paths
! FIX: add these to the io.pathnames vocab?

: path-list-separator ( -- string )
    os windows? ";" ":" ? ;

: path-list-separator? ( ch -- ? )
    path-list-separator member? ;

: path-list>string ( path-list -- string )
    path-list-separator join ;

: string>path-list ( string -- seq )
    path-list-separator split harvest ;

! Printing to the listener

SYMBOL: listener

listener [ get-listener ] initialize ! FIX: doing this seems to avoid making the listener pop up when running listener-. - so can we use that to print scsynth output now?

: listener-output-stream ( -- stream )
    listener get [ listener-streams nip ] [ f ] if* ;

: listener-print ( string -- )
    listener-output-stream [ print ] with-output-stream ;

: listener-. ( object -- )
    listener-output-stream [ . ] with-output-stream ;

! :: follow-file ( file quot -- ) ! Watch FILE, running QUOT on each of its lines. The file continues to be monitored for additional lines. Note that this word will loop forever, so you should make sure to run it in a separate thread.
!     [ [ file f [
!             next-change changed>> +modify-file+ swap member? [
!                 file utf8 file-lines last quot call( line -- )
!             ] when
!         ] with-monitor
!         t
!       ] loop
!     ] with-monitors ;

! Following files

:: follow-file ( file quot -- ) ! Watch FILE, running QUOT on each of its lines. The file continues to be monitored for additional lines. Note that this word will loop forever, so you should make sure to run it in a separate thread.
    [ [ file f [
            next-change changed>> +modify-file+ swap member? [
                file utf8 file-lines last quot call( line -- )
            ] when
        ] with-monitor
        t
      ] loop
    ] with-monitors ;

: start-file-follow-thread ( file quot thread-name -- thread )
    [ [ follow-file ] 2curry ] dip spawn ;

! "Deferred" classes

TUPLE: sc-server ;
