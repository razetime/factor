! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel kernel.private alien.accessors sequences
sequences.private math ;
IN: byte-arrays

M: byte-array clone (clone) ;
M: byte-array length length>> ;
M: byte-array nth-unsafe swap >fixnum alien-unsigned-1 ;
M: byte-array set-nth-unsafe swap >fixnum set-alien-unsigned-1 ;
: >byte-array ( seq -- byte-array ) B{ } clone-like ; inline
M: byte-array like drop dup byte-array? [ >byte-array ] unless ;
M: byte-array new-sequence drop <byte-array> ;

M: byte-array equal?
    over byte-array? [ sequence= ] [ 2drop f ] if ;

M: byte-array resize
    resize-byte-array ;

INSTANCE: byte-array sequence
