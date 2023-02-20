USING: kernel combinators namespaces
sequences arrays
calendar
io.backend io.sockets
threads concurrency.mailboxes
system xdg
osc ;

IN: supercollider

! common

SYMBOLS: sc-data-directory sc-synthdef-directory ;

sc-data-directory [
    xdg-data-home normalize-path "/SuperCollider" append
] initialize

sc-synthdef-directory [
    os {
        { linux [ xdg-data-home normalize-path ] }
        { macosx [ P" ~/Library/Application Support/SuperCollider/synthdefs/" normalize-path ] }
        { windows [ P" /SuperCollider/synthdefs/" normalize-path ] }
    } case
] initialize

! server

SYMBOLS: sc-timeout sc-server sc-socket sc-reader-thread sc-server-responses ;

sc-timeout [ 1 seconds ] initialize

sc-server [ "127.0.0.1" 57110 <inet4> ] initialize

: init-socket ( -- )
    sc-socket get
    [ f 0 <inet4> <datagram> sc-socket set
      ! sc-timeout get sc-socket get set-timeout
    ] unless ;

: init-mailbox ( -- )
    sc-server-responses get mailbox?
    [ <mailbox> sc-server-responses set ] unless ;

: from-sc-server? ( addr-spec -- ? )
    sc-server get = ;

: start-reader-thread ( -- )
    sc-reader-thread get thread?
    [
        [ [ sc-socket get receive from-sc-server?
            [ sc-server-responses get mailbox-put ]
            [ drop yield ] if t ] loop ]
        "SC-Reader" spawn sc-reader-thread set
    ] unless ;

: connect-sc ( -- )
    init-socket
    init-mailbox
    start-reader-thread ;

: (send-msg) ( addr params -- )
    osc-message sc-server get sc-socket get send ;

: get-reply ( -- msg )
    sc-server-responses get sc-timeout get mailbox-get-timeout ;

: send-msg ( addr params -- addr params )
    (send-msg)
    get-reply osc> ;
