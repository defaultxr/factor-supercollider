! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays hashtables io.files io.pathnames kernel
math namespaces sequences supercollider.server supercollider.syntax
supercollider.utility ;
IN: supercollider.buffer

TUPLE: buffer
    { id integer }
    { frames integer }
    { channels integer }
    { sample-rate integer }
    { path pathname }
    { server sc-server }
    { metadata hashtable } ;

: <buffer> ( id frames channels sample-rate -- buffer )
    buffer new
    swap >>sample-rate
    swap >>channels
    swap >>frames
    swap >>id
    sc-server get >>server ;

GENERIC: buffer-id ( buffer-or-id -- id ) ! Get the ID of a buffer object. If an integer is provided, simply return it as is.

M: buffer buffer-id
    id>> ;

M: integer buffer-id ;

SC: sc-server-buffer-alloc ( sc-server buffer-id frames channels -- addr params )
3array "/b_alloc" swap msg-sc-server ;

! SC: sc-server-buffer-alloc* ( sc-server buffer frames channels completion-msg -- )
!     ;

! FIX: make a variant that accepts completion-msg
SC: sc-server-buffer-alloc-read ( sc-server buffer-id path -- addr params )
dup file-exists? [ "file does not exist: " prepend throw ] unless
2array "/b_allocRead" swap msg-sc-server ; ! FIX: /b_query afterwards to get sample-rate and such

! FIX: make a variant that accepts completion-msg
SC: sc-server-buffer-alloc-read-section ( sc-server buffer-id path start-frame end-frame -- addr params ) ! FIX: actually use the start-frame and end-frame arguments
2drop dup file-exists? [ "file does not exist: " prepend throw ] unless
2array "/b_allocRead" swap msg-sc-server ; ! FIX: /b_query afterwards to get sample-rate and such

! FIX: /b_allocReadChannel

! FIX: make variants for reading only a section and for completion-msg
SC: sc-server-buffer-read ( sc-server buffer-id path -- addr params )
2array "/b_read" swap msg-sc-server ;

! FIX: /b_readChannel

! FIX: make variants for writing only a section and for completion-msg
SC: sc-server-buffer-write ( sc-server buffer path header-format sample-format -- addr params )
[ [ buffer-id ]
  [ dup file-exists? [ "file does not exist: " prepend throw ] unless ] bi*
] 2dip
! FIX: validate that the header-format and sample-format are correct
4array "/b_write" msg-sc-server ;

! FIX: make a variant for completion-msg
SC: sc-server-buffer-free ( sc-server buffer -- addr params )
buffer-id 1array "/b_free" swap msg-sc-server ;

! FIX: make a variant for completion-msg
SC: sc-server-buffer-zero ( sc-server buffer -- addr params )
buffer-id 1array "/b_zero" swap msg-sc-server ;

! FIX:
! SC: sc-server-buffer-set ( sc-server buffer start-sample samples -- )
! "/b_set" swap (msg-sc-server) ;

SC: sc-server-buffer-setn ( sc-server buffer start-sample samples -- )
[ buffer-id ] 2dip dup length 1array prepend [ 2array ] dip append "/b_setn" swap (msg-sc-server) ;

! FIX: this command supports setting multiple ranges; implement that
SC: sc-server-buffer-fill ( sc-server buffer start-sample number-of-samples value -- )
[ buffer-id ] 3dip 4array "/b_fill" swap (msg-sc-server) ;

SC: sc-server-buffer-gen ( sc-server buffer fill-command command-arguments -- addr params )
[ buffer-id ] 2dip
! FIX: check that fill-command is valid
[ 2array ] dip append "/b_gen" swap msg-sc-server ;

! FIX: make a variant with completion-msg
SC: sc-server-buffer-close ( sc-server buffer -- addr params )
buffer-id 1array "/b_close" swap msg-sc-server ;

! FIX: parse the buffer-info-array to something more usable?
SC: sc-server-buffer-query ( sc-server buffers -- buffer-info-array )
ensure-array [ buffer-id ] map "/b_query" swap msg-sc-server nip ;

SC: sc-server-buffer-get ( sc-server buffer sample-indexes -- sample-values )
ensure-array [ 1array ] dip append "/b_get" swap msg-sc-server nip ;

! FIX: make the indexes-and-num-samples argument easier to use, and parse the sample-values array to something more usable.
SC: sc-server-buffer-getn ( sc-server buffer indexes-and-num-samples -- sample-values-array )
[ buffer-id 1array ] dip append "/b_getn" swap msg-sc-server nip ;

CONSTANT: +normalize+ 1
CONSTANT: +wavetable+ 2
CONSTANT: +clear+ 4

: sum-buffer-fill-flags ( flags -- array )
    ensure-array 0 [ + ] reduce 1array ;

<PRIVATE

: buffer-fill-array ( flags partial-amplitudes -- array )
    [ sum-buffer-fill-flags ] [ ensure-array ] bi* append ;

PRIVATE>

: buffer-fill-sine1 ( flags partial-amplitudes -- command array )
    buffer-fill-array "sine1" swap ;

: buffer-fill-sine2 ( flags partial-frequencies-and-amplitudes -- command array )
    buffer-fill-array "sine2" swap ;

: buffer-fill-sine3 ( flags partial-frequencies-amplitudes-and-phases -- command array )
    buffer-fill-array "sine3" swap ;

: buffer-fill-cheby ( flags amplitudes -- command array )
    buffer-fill-array "cheby" swap ;

: buffer-fill-copy ( destination-sample-index source-buffer source-sample-index num-samples -- command array )
    [ buffer-id ] 2dip 4array "copy" swap ;

! FIX: also make a sc-server-buffer-copy word for convenience
