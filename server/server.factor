! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar combinators
concurrency.mailboxes io io.backend io.files.temp io.sockets
kernel make math math.parser memory namespaces osc sequences
strings supercollider.config supercollider.utility threads ;
IN: supercollider.server

! FIX: can buffer-size and sample-rate be auto-detected?
TUPLE: sc-server-options
    { control-buses initial: 16384 }
    { audio-buses initial: 1024 }
    { input-buses initial: 8 }
    { output-buses initial: 8 }
    { block-size initial: 64 }
    { buffer-size initial: 0 }
    { sample-rate initial: 0 }
    { sample-buffers initial: 1024 }
    { max-nodes initial: 1024 }
    { max-synthdefs initial: 1024 }
    { realtime-memory-size initial: 8192 }
    { wire-buffers initial: 64 }
    { random-seeds initial: 64 }
    { load-synthdefs? initial: t }
    { publish-to-rendezvous? initial: t }
    { max-logins initial: 64 }
    { verbosity initial: 0 }
    { plugin-directories array }
    { device-name string initial: "factor-collider" } ;

: <sc-server-options> ( -- options )
    sc-server-options new
    sc-plugin-directories get [ normalize-path ] map >>plugin-directories ;

TUPLE: sc-server
    { host initial: "127.0.0.1" }
    { port initial: 57330 }
    { options sc-server-options }
    process ! will be f when the sc-server is not managed by Factor, and thus not killed by the shutdown hook.
    stdout
    output-reader-thread
    socket
    osc-reader-thread
    responses
    timeout ;

: <sc-server> ( -- sc-server )
    sc-server new
    <sc-server-options> >>options
    "supercollider-stdout.txt" temp-file >>stdout
    1 seconds >>timeout ;

sc-server [ <sc-server> ] initialize

: sc-server-address ( sc-server -- inet4 )
    [ host>> ] [ port>> ] bi <inet4> ;

: sc-server-init-socket ( sc-server -- )
    dup socket>>
    [ ! dup timeout>>
        f 0 <inet4> <datagram>
        ! [ set-timeout ] [ >>socket ] bi
        >>socket
        ! "/notify" { 1 } (msg-sc)
    ] unless drop ;

: sc-server-init-mailbox ( sc-server -- )
    dup responses>> mailbox?
    [ <mailbox> >>responses ] unless drop ;

: from-sc-server? ( addr-spec -- ? )
    sc-server get sc-server-address = ;

! FIX: is it possible to redirect process output to the listener? this doesn't seem to work...
! i asked in factor-help but they didn't seem to know either.
! https://discord.com/channels/780615045771821076/786055699271909428/1096565291414208612
! my guess is that "a file stream or a socket - the stream is connected to the given Factor stream, which cannot be used again from within Factor and must be closed after the process has been started" is the problem
! or maybe it's relating to the use of threads?
! : sc-server-start-output-reader-thread ( sc-server -- )
!     dup output-reader-thread>> thread?
!     [ [ get-listener [ listener-streams nip ] [ f ] if* swap
!         [ process>> ascii <process-stream>
!           [ [ print flush ] each-line ] with-input-stream*
!         ] with-output-stream
!       ] "SuperCollider output reader thread" spawn >>output-reader-thread
!     ] unless drop ;

: sc-server-start-output-reader-thread ( sc-server -- )
    dup output-reader-thread>> thread? [
        dup stdout>>
        listener-output-stream [ [ print ] with-output-stream ] curry
        "SuperCollider output reader thread" start-file-follow-thread >>output-reader-thread
    ] unless drop ;

:: sc-server-start-osc-reader-thread ( sc-server -- )
    sc-server osc-reader-thread>> thread?
    [ [ [ sc-server socket>> receive from-sc-server?
          [ sc-server responses>> mailbox-put ]
          [ drop yield ] if
          t
        ] loop
      ] "SuperCollider OSC reader thread" spawn sc-server swap >>osc-reader-thread drop
    ] unless ;

: connect-sc-server ( sc-server -- )
    { [ sc-server-init-socket ]
      [ sc-server-init-mailbox ]
      [ sc-server-start-output-reader-thread ]
      [ sc-server-start-osc-reader-thread ] } cleave ;

: with-sc-server ( sc-server quot -- ... )
    sc-server swap with-variable ; inline

: (msg-sc-server) ( server addr params -- )
    osc-message swap [ sc-server-address ] [ socket>> ] bi send ;

: (msg-sc) ( addr params -- ) ! osc-message sc-server get [ sc-server-address ] [ socket>> ] bi send
    sc-server get -rot (msg-sc-server) ;

: get-reply ( sc-server -- msg )
    [ responses>> ] [ timeout>> ] bi mailbox-get-timeout ;

: msg-sc-server ( sc-server addr params -- addr params )
    pick [ (msg-sc-server) ] dip get-reply osc> ;

: msg-sc ( addr params -- addr params )
    (msg-sc) sc-server get get-reply osc> ;

: scsynth-arguments ( sc-server -- args )
    [ "scsynth" ,
      [ "-u" , port>> number>string , ]
      [ options>> { [ "-H" , device-name>> , ]
                    [ "-c" , control-buses>> number>string , ]
                    [ "-a" , audio-buses>> number>string , ]
                    [ "-i" , input-buses>> number>string , ]
                    [ "-o" , output-buses>> number>string , ]
                    [ "-z" , block-size>> number>string , ]
                    [ "-Z" , buffer-size>> number>string , ]
                    [ "-S" , sample-rate>> number>string , ]
                    [ "-b" , sample-buffers>> number>string , ]
                    [ "-n" , max-nodes>> number>string , ]
                    [ "-d" , max-synthdefs>> number>string , ]
                    [ "-m" , realtime-memory-size>> number>string , ]
                    [ "-w" , wire-buffers>> number>string , ]
                    [ "-r" , random-seeds>> number>string , ]
                    [ "-D" , load-synthdefs?>> boolean>number number>string , ]
                    [ "-R" , publish-to-rendezvous?>> boolean>number number>string , ]
                    [ "-l" , max-logins>> number>string , ]
                    [ "-V" , verbosity>> number>string , ]
                    [ "-U" , plugin-directories>> path-list-string , ]
                  } cleave
      ] bi
    ] { } make ;

: sc-servers ( -- servers )
    [ sc-server? ] instances [ timeout>> ] filter ; ! We check the timeout in order to filter out the tuple "prototype". There may be a better way to do this.

: sc-server-running? ( sc-server -- ? )
    process>>
    [ status>> not ]
    [ f ] if* ;

: sc-running? ( -- ? )
    sc-server get sc-server-running? ;

: running-sc-servers ( -- servers )
    sc-servers [ sc-server-running? ] filter ;

: any-sc-running? ( -- ? )
    running-sc-servers length 0 > ;

! : local-sc-servers ( -- servers ) ! Get an array of sc-servers that were started by Factor. FIX - come up with a better name, as "local" already has a meaning for servers/SuperCollider.
!     1 ; ! FIX

! : remote-sc-servers ( -- servers ) ! Get an array of sc-servers that were not started by Factor.
!     1 ; ! FIX
