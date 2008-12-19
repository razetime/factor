USING: formatting words classes.mixin kernel fry compiler.units
       accessors classes classes.tuple ;

IN: mongodb.persistent

MIXIN: persistent-tuple

SLOT: _p_oid
SLOT: _p_info

TUPLE: oid { a initial: 0 } { b initial: 0 } ;

TUPLE: persistent-info type vocab collection dirty? mt ;

<PRIVATE

: P_VOCAB ( -- string )
    "mongodb.persistent" ; inline

: P_SLOTS ( -- array )
    { "_p_oid" "_p_info" } ;

: define-persistent-tuple ( class name -- class )
    P_VOCAB create ! class word
    dup dup '[ _  _ [  ] curry define ] with-compilation-unit
    dup [ swap ] dip
    '[ _ _ P_SLOTS define-tuple-class
        _ persistent-tuple define-mixin-class ] with-compilation-unit ; 

    
PRIVATE>

GENERIC: persistent-tuple-class ( tuple -- class )

M: tuple persistent-tuple-class ( tuple -- class )
    class persistent-tuple-class ;

M: tuple-class persistent-tuple-class ( class -- class' )
    [ [ vocabulary>> ] [ name>> ] bi ] keep ! name vocab class
    [ "%s_%s" sprintf ] dip swap dup   ! class new_name new_name
    P_VOCAB lookup dup                 ! class new_name vo/f vo/f
    [ [ drop drop ] dip ] [ drop define-persistent-tuple ] if ;
