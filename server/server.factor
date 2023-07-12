! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar combinators
combinators.short-circuit concurrency.conditions
concurrency.mailboxes continuations init io io.backend
io.files.temp io.launcher io.sockets kernel make math
math.parser memory namespaces osc sequences strings
supercollider.config supercollider.syntax supercollider.utility
threads ;
IN: supercollider.server

! FIX: can buffer-size and sample-rate be auto-detected? A: sample-rate can be, from /status.reply
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

IN: supercollider.utility ! needed here to prevent the TUPLE below from defining a separate/conflicting "sc-server"

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
    timeout
    { next-node-id integer initial: 1000 } ;

IN: supercollider.server

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

: (msg-sc-server) ( sc-server addr params -- )
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

SC: start-sc-server ( sc-server -- )
[ dup [ scsynth-arguments ]
  [ stdout>> ] bi
  <process>
  swap >>stdout
  swap >>command
  "supercollider-stderr.txt" temp-file >>stderr
  run-detached >>process drop ]
[ connect-sc-server ] bi ;

SC: quit-sc-server ( sc-server -- )
"/quit" { } msg-sc-server 2drop ;

SC: kill-sc-server ( sc-server -- )
process>> kill-process ;

SC: stop-sc-server ( sc-server -- )
{ [ [ quit-sc-server t ] curry [ timed-out-error? ] ignore-error/f ]
  [ kill-sc-server t ] } 1|| drop ;

: stop-all-sc-servers ( -- )
    sc-servers [ stop-sc-server ] each ;

[ stop-all-sc-servers ] "stop supercollider" add-shutdown-hook

SC: sc-server-notify ( sc-server enable? -- )
boolean>number 1array "/notify" swap (msg-sc-server) ;

SC: sc-server-notify-enable ( sc-server -- )
1 1array "/notify" swap (msg-sc-server) ;

SC: sc-server-notify-disable ( sc-server -- )
0 1array "/notify" swap (msg-sc-server) ;

SC: sc-server-notify-client ( sc-server enable? client-id -- )
[ boolean>number ] dip 2array "/notify" swap (msg-sc-server) ;

SC: sc-server-notify-enable-client ( sc-server client-id -- )
1 swap 2array "/notify" swap (msg-sc-server) ;

SC: sc-server-notify-disable-client ( sc-server client-id -- )
0 swap 2array "/notify" swap (msg-sc-server) ;

SC: sc-server-status ( sc-server -- assoc ) ! Get an assoc of various information about the status of the SuperCollider server. In particular: the number of active UGens, the number of active synths, the number of groups, the number of loaded synthdefs, the CPU usage average percent, the peak CPU usage percent, the nominal sample rate, and the actual sample rate.
"/status" { } msg-sc-server nip rest { "ugens" "synths" "groups" "synthdefs" "cpu-average" "cpu-peak" "nominal-sample-rate" "actual-sample-rate" } swap 2array flip ;

SC: sc-server-plugin-command ( sc-server command args -- )
[ 1array ] dip append "/cmd" swap (msg-sc-server) ;

CONSTANT: +dump-off+ 0

CONSTANT: +dump-parsed+ 1

CONSTANT: +dump-hex+ 2

CONSTANT: +dump-parsed-and-hex+ 3

SC: sc-server-dump-osc ( sc-server flag -- )
dup boolean? [ boolean>number ] when 1array "/dumpOSC" swap (msg-sc-server) ;

SC: sc-server-dump-osc-enable ( sc-server -- )
"/dumpOSC" { 1 } (msg-sc-server) ;

SC: sc-server-dump-osc-disable ( sc-server -- )
"/dumpOSC" { 0 } (msg-sc-server) ;

! FIX: detect that the identifier integer matches
SC: sc-server-sync ( sc-server n -- )
1array "/sync" swap msg-sc-server 2drop ;

SC: sc-server-clear-scheduled ( sc-server -- )
"/clearSched" { } (msg-sc-server) ;

CONSTANT: +error-reporting-off+ 0

CONSTANT: +error-reporting-on+ 1

CONSTANT: +error-reporting-off-bundle+ -1

CONSTANT: +error-reporting-on-bundle+ -2

SC: sc-server-report-errors ( sc-server mode -- )
dup boolean? [ boolean>number ] when 1array "/error" swap (msg-sc-server) ;

SC: sc-server-version ( sc-server -- assoc )
"/error" { } msg-sc-server nip { "program" "major-version" "minor-version" "patch-version" "git-branch" "git-commit" } swap 2array flip ;

SC: sc-server-next-node-id ( sc-server -- integer ) ! Get the next available node ID on the server. See also: `sc-server-get-next-node-id`
next-node-id>> ;

SC: sc-server-get-next-node-id ( sc-server -- integer ) ! Grab the next available node ID on the server. The ID is then reserved and will not be used again. See also: `sc-server-next-node-id`
[ next-node-id>> ]
[ [ 1 + ] change-next-node-id drop ] bi ;
