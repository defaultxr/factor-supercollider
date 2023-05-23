! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators io.backend io.pathnames namespaces sequences
system xdg ;
IN: supercollider.config

SYMBOLS: sc-data-directory sc-plugin-directories sc-synthdef-directory ;

sc-data-directory [
    os { { linux [ xdg-data-home normalize-path "/SuperCollider" append ] }
         { macosx [ P" ~/Library/Application Support/SuperCollider" normalize-path ] }
         { windows [ P" C:\\Program Files\\SuperCollider" normalize-path ] } ! FIX: this might not be accurate
       } case
] initialize

sc-plugin-directories [
    os { { linux [ { "/usr/lib/SuperCollider/plugins" "/usr/share/SuperCollider/Extensions" } ] }
         { macosx [ { } ] } ! FIX
         { windows [ { } ] } ! FIX
       } case    
] initialize

sc-synthdef-directory [
    sc-data-directory get path-separator "synthdefs" 3append
] initialize

