! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
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

IN: inference
USE: combinators
USE: dataflow
USE: errors
USE: interpreter
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: stack
USE: strings
USE: vectors
USE: words
USE: hashtables

: branch-effect ( -- [ dataflow [ in-d | datastack ] ] )
    get-dataflow  d-in get meta-d get cons  cons ;

: infer-branch ( quot -- [ dataflow [ in-d | datastack ] ] )
    #! Infer the quotation's effect, restoring the meta
    #! interpreter state afterwards.
    [
        copy-interpreter
        dataflow-graph off
        (infer)
        branch-effect
    ] with-scope ;

: difference ( [ in | stack ] -- diff )
    #! Stack height difference of infer-branch return value.
    uncons vector-length - ;

: balanced? ( list -- ? )
    #! Check if a list of [ in | stack ] pairs has the same
    #! stack height.
    [ difference ] map all=? ;

: max-vector-length ( list -- length )
    [ vector-length ] map [ > ] top ;

: unify-lengths ( list -- list )
    #! Pad all vectors to the same length. If one vector is
    #! shorter, pad it with unknown results at the bottom.
    dup max-vector-length swap [ dupd ensure nip ] map nip ;

: unify-result ( obj obj -- obj )
    #! Replace values with unknown result if they differ,
    #! otherwise retain them.
    2dup = [ drop ] [ 2drop gensym ] ifte ;

: unify-stacks ( list -- stack )
    #! Replace differing literals in stacks with unknown
    #! results.
    uncons [ [ unify-result ] vector-2map ] each ;

: unify ( list -- )
    #! Unify meta-interpreter state from two branches.
    [ ] subset ! Filter terminator slots
    dup balanced? [
        unzip
        unify-lengths unify-stacks meta-d set
        [ > ] top d-in set
    ] [
        "Unbalanced branches" throw
    ] ifte ;

: terminator? ( quot -- ? )
    #! This is a hack. no-method has a stack effect that
    #! probably does not match any other branch of the generic,
    #! so we handle it specially.
    \ no-method swap tree-contains? ;

: recursive-branch ( quot -- )
    #! Set base case if inference didn't fail.
    [
        infer-branch cdr recursive-state get set-base
    ] [
        [ drop ] when
    ] catch ;

: (infer-branches) ( branchlist -- dataflowlist effectlist )
    dup [
        car dup terminator? [ drop ] [ recursive-branch ] ifte
    ] each
    [
        car dup terminator? [
            infer-branch car f cons
        ] [
            infer-branch
        ] ifte
    ] map
    unzip ;

: infer-branches ( inputs instruction branchlist -- )
    #! Recursive stack effect inference is done here. If one of
    #! the branches has an undecidable stack effect, we set the
    #! base case to this stack effect and try again. The inputs
    #! parameter is a vector.
    (infer-branches) >r
    swap dataflow, [ node-consume-d set ] bind
    r> unify ;

: infer-ifte ( -- )
    #! Infer effects for both branches, unify.
    3 ensure-d
    dataflow-drop, pop-d
    dataflow-drop, pop-d 2list
    >r 1 meta-d get vector-tail* #ifte r>
    pop-d drop ( condition )
    infer-branches ;

: vtable>list ( [ vtable | rstate ] -- list )
    #! generic and 2generic use vectors of words, we need lists
    #! of quotations. Filter out no-method. Dirty workaround;
    #! later properly handle throw.
    unswons vector>list [ unit over cons ] map nip ;

: infer-generic ( -- )
    #! Infer effects for all branches, unify.
    2 ensure-d
    dataflow-drop, pop-d vtable>list
    >r 1 meta-d get vector-tail* #generic r>
    infer-branches ;

: infer-2generic ( -- )
    #! Infer effects for all branches, unify.
    3 ensure-d
    dataflow-drop, pop-d vtable>list
    >r 2 meta-d get vector-tail* #2generic r>
    infer-branches ;

\ ifte [ infer-ifte ] "infer" set-word-property

\ generic [ infer-generic ] "infer" set-word-property
\ generic [ 2 | 0 ] "infer-effect" set-word-property

\ 2generic [ infer-2generic ] "infer" set-word-property
\ 2generic [ 3 | 0 ] "infer-effect" set-word-property
