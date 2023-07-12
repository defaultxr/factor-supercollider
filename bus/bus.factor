! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel sequences supercollider.server
supercollider.syntax supercollider.utility ;
IN: supercollider.bus

! FIX: allow setting multiple buses at once
SC: sc-server-bus-set ( sc-server bus value -- )
2array "/c_set" swap (msg-sc-server) ;

! FIX: allow setting multiple buses at once
SC: sc-server-bus-set-n ( sc-server starting-bus values -- )
dup length swap [ 2array ] dip append "/c_setn" swap (msg-sc-server) ;

! FIX: allow setting multiple buses at once
SC: sc-server-bus-fill ( sc-server starting-bus values -- )
dup length swap [ 2array ] dip append "/c_fill" swap (msg-sc-server) ;

SC: sc-server-bus-get ( sc-server buses -- values )
ensure-array "/c_get" swap msg-sc-server nip ;

! FIX: allow setting multiple buses at once
SC: sc-server-bus-get-n ( sc-server starting-bus n -- values )
2array "/c_getn" swap msg-sc-server nip ;
