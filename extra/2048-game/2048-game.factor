! Copyright (C) 2023 Raghu Ranganathan
! See https://factorcode.org/license.txt for BSD license.
USING: arrays images.loader kernel lists math math.matrices
random sequences ui.gestures combinators sorting prettyprint
math.functions math.parser io ascii math.order grouping ;
IN: 2048-game

: new-grid ( -- grid ) {
  { 0 0 0 0 }
  { 0 0 0 0 }
  { 0 0 0 0 }
  { 0 0 0 0 }
} [ clone ] map clone ;

! 0 - left, 1 - down, 2 - right, 3 - up
:: move1d ( seq n -- seq n )
n seq nth :> curr
n 1 + seq nth :> nxt
{
  { [ nxt zero? ] [
    0 n seq set-nth
    curr n 1 + seq set-nth
    seq n 1 +
  ] }
  { [ curr nxt = ] [
    0 n seq set-nth
    curr nxt + n 1 + seq set-nth
    seq n 2 +
  ] }
  [ seq n 1 + ]
} cond
;


! { { 0 0 2 2 } { 0 0 2 2 } { 0 0 2 2 } { 0 0 2 2 } }

: rot90 ( m -- m' ) reverse flip ;

: random-4x4 ( grid -- r,c )
  [ swap 0 swap indices [ dupd 2array ] map nip ] map-index
  concat random ;

: get-move ( -- move )
  4 [ dup 0 3 between? not ]
  [
    drop "Enter move (0 - right, 1 - up, 2 - left, 3 - down)" print
    read1 48 -
  ] do while
;

: set-random ( num grid -- grid ) swap over dup random-4x4 swap matrix-set-nth ;

: disp-matrix ( matrix -- ) [ [ >dec ] map " " join ] map "\n" join print ;

:: move-board ( grid dir -- grid )
  grid dir [ rot90 ] times
  [ 
    0 [ 2dup swap length 1 - < ] [ move1d ] while drop
    [ signum ] sort-by
  ] map
  4 dir - [ rot90 ] times
; 

: game-cycle ( grid -- grid ) 
    { 2 4 } random swap set-random
    dup simple-table.
    get-move move-board
;

: game-over? ( grid -- t/f )
    dup flip append 
    [
      [ [ zero? ] any? ]
      [ 2 <clumps> [ first2 = ] any? ] bi or
    ] any? 
;

:: play-2048 ( -- )
  new-grid 2 swap set-random :> g
  g [ dup game-over? ] [ game-cycle ] while drop
;



