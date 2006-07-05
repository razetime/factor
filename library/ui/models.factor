! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: models
USING: generic kernel math sequences ;

TUPLE: model connections value dependencies ref ;

M: model = eq? ;

C: model ( value -- model )
    [ set-model-value ] keep
    V{ } clone over set-model-connections
    V{ } clone over set-model-dependencies
    0 over set-model-ref ;

: add-dependency ( model model -- )
    model-dependencies push ;

: remove-dependency ( model model -- )
    model-dependencies delete ;

DEFER: add-connection

: ref-model ( model -- n )
    dup model-ref 1+ dup rot set-model-ref ;

: unref-model ( model -- n )
    dup model-ref 1- dup rot set-model-ref ;

: activate-model ( model -- )
    dup ref-model 1 = [
        dup model-dependencies
        [ dup activate-model add-connection ] each-with
    ] [
        drop
    ] if ;

DEFER: remove-connection

: deactivate-model ( model -- )
    dup unref-model zero? [
        dup model-dependencies
        [ dup deactivate-model remove-connection ] each-with
    ] [
        drop
    ] if ;

GENERIC: model-changed ( observer -- )

: add-connection ( obj model -- )
    dup model-connections empty? [ dup activate-model ] when
    model-connections push ;

: remove-connection ( obj model -- )
    [ model-connections delete ] keep
    dup model-connections empty? [ dup deactivate-model ] when
    drop ;

: set-model ( value model -- )
    2dup model-value = [
        2drop
    ] [
        [ set-model-value ] keep
        model-connections [ model-changed ] each
    ] if ;

: change-model ( model quot -- )
    over >r >r model-value r> call r> set-model ; inline

: delegate>model ( obj -- )
    f <model> swap set-delegate ;

TUPLE: filter model quot ;

C: filter ( model quot -- filter )
    dup delegate>model
    [ set-filter-quot ] keep
    [ set-filter-model ] 2keep
    [ add-dependency ] keep
    dup model-changed ;

M: filter model-changed ( filter -- )
    dup filter-model model-value over filter-quot call
    swap set-model ;

TUPLE: compose ;

C: compose ( models -- compose )
    dup delegate>model
    [ set-model-dependencies ] keep
    dup model-changed ;

M: compose model-changed ( compose -- )
    dup model-dependencies [ model-value ] map
    swap set-model ;

TUPLE: history back forward ;

C: history ( -- history )
    dup delegate>model
    V{ } clone over set-history-back
    V{ } clone over set-history-forward ;

: (add-history) ( history vector -- )
    swap model-value dup [ swap push ] [ 2drop ] if ;

: go-back/forward ( history to from -- )
    dup empty?
    [ 3drop ]
    [ >r dupd (add-history) r> pop swap set-model ] if ;

: go-back ( history -- )
    dup history-forward over history-back go-back/forward ;

: go-forward ( history -- )
    dup history-back over history-forward go-back/forward ;

: add-history ( history -- )
    0 over history-forward set-length
    dup history-back (add-history) ;
