! Copyright (C) 2023 modula t. worm.
! See https://factorcode.org/license.txt for BSD license.
USING: ;
IN: supercollider.spec.specs

control-spec new "freq" >>name 20 >>min 20000 >>max exponential >>warp

control-spec new "unipolar" >>name 0 >>min 1 >>max

control-spec new "bipolar" >>name -1 >>min 1 >>max

! TUPLE: freq < control-spec
!     { min initial: 20 read-only }
!     { max initial: 20000 read-only }
!     { warp initial: exponential read-only } ;

! TUPLE: unipolar < control-spec
!     { min initial: 0 read-only }
!     { max initial: 1 read-only } ;

! TUPLE: bipolar < control-spec
!     { min initial: -1 read-only }
!     { max initial: 1 read-only } ;

