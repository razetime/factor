! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: prettyprint
USE: combinators
USE: errors
USE: format
USE: kernel
USE: logic
USE: lists
USE: math
USE: namespaces
USE: prettyprint
USE: stack
USE: stdio
USE: strings
USE: presentation
USE: unparser
USE: vectors
USE: words

: tab-size
    #! Change this to suit your tastes.
    4 ;

: prettyprint-limit ( -- limit )
    #! Avoid infinite loops -- maximum indent, 10 levels.
    "prettyprint-limit" get [ 40 ] unless* ;

: prettyprint-indent ( indent -- )
    #! Print the given number of spaces.
    " " fill write ;

: prettyprint-newline ( indent -- )
    "\n" write prettyprint-indent ;

: prettyprint-space ( -- )
    " " write ;

: newline-after? ( obj -- ? )
    comment? ;

! Real definition follows
DEFER: prettyprint*

: prettyprint-element ( indent obj -- indent )
    dup >r prettyprint* r> newline-after? [
        dup prettyprint-newline
    ] [
        prettyprint-space
    ] ifte ;

: <prettyprint ( indent -- indent )
    tab-size +
    "prettyprint-single-line" get [
        prettyprint-space
    ] [
        dup prettyprint-newline
    ] ifte ;

: prettyprint> ( indent -- indent )
    tab-size -
    "prettyprint-single-line" get [
        dup prettyprint-newline
    ] unless ;

: prettyprint-[ ( indent -- indent )
    "[" write <prettyprint ;

: prettyprint-] ( indent -- indent )
    prettyprint> "]" write ;

: prettyprint-list ( indent list -- indent )
    #! Pretty-print a list, without [ and ].
    [
        uncons >r prettyprint-element r>
        dup cons? [
            prettyprint-list
        ] [
            [
                "|" write prettyprint-space prettyprint-element
            ] when*
        ] ifte
    ] when* ;

: prettyprint-[] ( indent list -- indent )
    swap prettyprint-[ swap prettyprint-list prettyprint-] ;

: prettyprint-{ ( indent -- indent )
    "{" write <prettyprint ;

: prettyprint-} ( indent -- indent )
    prettyprint> "}" write ;

: prettyprint-vector ( indent list -- indent )
    #! Pretty-print a vector, without { and }.
    [ prettyprint-element ] vector-each ;

: prettyprint-{} ( indent vector -- indent )
    dup vector-length 0 = [
        drop "{ }" write
    ] [
        swap prettyprint-{ swap prettyprint-vector prettyprint-}
    ] ifte ;

: trim-newline ( str -- str )
    dup ends-with-newline? dup [ nip ] [ drop ] ifte ;

: prettyprint-comment ( comment -- )
    trim-newline "comments" style write-attr ;

: word-link ( word -- link )
    [
        "vocabularies'" ,
        dup word-vocabulary ,
        "'" ,
        word-name ,
    ] make-string ;

: word-actions ( -- list )
    [
        [ "Describe" | "describe-path"  ]
        [ "Push"     | "lookup"         ]
        [ "Execute"  | "lookup execute" ]
        [ "jEdit"    | "lookup jedit"   ]
        [ "Usages"   | "lookup usages." ]
    ] ;

: word-attrs ( word -- attrs )
    #! Words without a vocabulary do not get a link or an action
    #! popup.
    dup word-vocabulary [
        word-link [ "object-link" swons ] keep
        word-actions <actions> "actions" swons
        t "underline" swons
        3list
    ] [
        drop [ ]
    ] ifte ;

: prettyprint-word ( word -- )
    dup word-name
    swap dup word-attrs swap word-style append
    write-attr ;

: prettyprint-object ( indent obj -- indent )
    unparse write ;

: prettyprint* ( indent obj -- indent )
    over prettyprint-limit >= [
        unparse write
    ] [
        [
            [ f =       ] [ prettyprint-object ]
            [ cons?     ] [ prettyprint-[] ]
            [ vector?   ] [ prettyprint-{} ]
            [ comment?  ] [ prettyprint-comment ]
            [ word?     ] [ prettyprint-word ]
            [ drop t    ] [ prettyprint-object ]
        ] cond
    ] ifte ;

: prettyprint ( obj -- )
    0 swap prettyprint* drop terpri ;

: vocab-link ( vocab -- link )
    "vocabularies'" swap cat2 ;

: vocab-attrs ( word -- attrs )
    vocab-link "object-link" default-style acons ;

: prettyprint-vocab ( vocab -- )
    dup vocab-attrs write-attr ;

: prettyprint-IN: ( indent word -- )
    \ IN: prettyprint-word prettyprint-space
    word-vocabulary prettyprint-vocab prettyprint-newline ;

: prettyprint-: ( indent -- indent )
    \ : prettyprint-word prettyprint-space
    tab-size + ;

: prettyprint-; ( indent -- indent )
    \ ; prettyprint-word
    tab-size - ;

: prettyprint-plist ( word -- )
    dup "parsing" word-property [ " parsing" write ] when
    "inline" word-property [ " inline" write ] when ;

: . ( obj -- )
    [
        "prettyprint-single-line" on
        tab-size 4 * "prettyprint-limit" set
        prettyprint
    ] with-scope ;

: [.] ( list -- )
    #! Unparse each element on its own line.
    [ . ] each ;

: {.} ( vector -- )
    #! Unparse each element on its own line.
    [ . ] vector-each ;

: .n namestack  {.} ;
: .s datastack  {.} ;
: .r callstack  {.} ;
: .c catchstack {.} ;

! For integers only
: .b >bin print ;
: .o >oct print ;
: .h >hex print ;
