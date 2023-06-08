! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays grouping hashtables io io.encodings.utf8
io.files io.monitors kernel math prettyprint sequences system
threads ui.tools.listener ;
IN: supercollider.utility

! Booleans

: boolean>number ( boolean -- number )
    1 0 ? ;

: number>boolean ( boolean -- number )
    0 > ;

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

: path-list-separator ( -- string ) ! FIX: add this to the io.pathnames vocab?
    os windows? ";" ":" ? ;

: path-list-string ( path-list -- string ) ! FIX: add this to the io.pathnames vocab?
    path-list-separator join ;

! Printing to the listener

: listener-output-stream ( -- stream )
    get-listener [ listener-streams nip ] [ f ] if* ;

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

