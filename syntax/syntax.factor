! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar combinators concurrency.mailboxes
definitions effects effects.parser io io.backend io.files.temp
io.sockets kernel make math math.parser memory namespaces osc parser
quotations sequences splitting strings supercollider.config
supercollider.utility threads words ;
IN: supercollider.syntax

: make-non-server-word-name ( symbol -- symbol' )
    name>> "-server" "" replace create-word-in ;

: make-non-server-definition ( server-word-name -- def )
    1quotation [ sc-server get ] prepend ;

: make-non-server-effect ( effect -- effect' )
    [ in>> "sc-server" swap remove ]
    [ out>> ] bi
    <effect> ;

: make-non-server-word ( word def effect -- word def effect )
    nip
    [ [ make-non-server-word-name ]
      [ make-non-server-definition ] bi ]
    [ make-non-server-effect ] bi* ;

: (SC:) ( word def effect -- )
    [ define-declared ]
    [ make-non-server-word define-declared ] 3bi ;

SYNTAX: SC: (:) (SC:) ;
