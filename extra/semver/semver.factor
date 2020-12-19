! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.short-circuit
combinators.smart kernel math math.parser multiline peg.ebnf
sequences sequences.deep splitting strings ;
IN: semver

! caret - up to next major versions, aka only major version needs to match
! tilde - last number can increment, e.g. ~1.2 is <2.0, ~1.2.3 is <1.3

: ?string>number ( str -- number/str )
    dup string>number dup not -rot ? ;

SINGLETONS: major minor patch prerelease build prepatch preminor premajor ;

TUPLE: semver
    { major integer initial: 0 }
    { minor integer initial: 0 }
    { patch integer initial: 0 }
    { prerelease initial: "" }
    { build initial: "" } ;

: parse-semver ( str -- semver )
    "+" split1
    [ "-" split1 ] dip
    [ "." split [ string>number ] map first3 ] 2dip
    semver boa ;

: first-semver-slot ( semver -- class )
    {
        { [ dup major>> 0 > ] [ drop major ] }
        { [ dup minor>> 0 > ] [ drop minor ] }
        { [ dup patch>> 0 > ] [ drop patch ] }
        { [ dup prerelease>> length 0 > ] [ drop prerelease ] }
        { [ dup build>> length 0 > ] [ drop build ] }
        [ drop major ]
    } cond ;

: last-semver-slot ( semver -- class )
    {
        { [ dup build>> length 0 > ] [ drop build ] }
        { [ dup prerelease>> length 0 > ] [ drop prerelease ] }
        { [ dup patch>> 0 > ] [ drop patch ] }
        { [ dup minor>> 0 > ] [ drop minor ] }
        { [ dup major>> 0 > ] [ drop major ] }
        [ drop major ]
    } cond ;

: semver>string ( semver -- string )
    [
        {
            [ major>> number>string "." ]
            [ minor>> number>string "." ]
            [ patch>> number>string ]
            [ prerelease>> [ "" "" ] [ "-" swap ] if-empty ]
            [ build>> [ "" "" ] [ "+" swap ] if-empty ]
        } cleave
    ] "" append-outputs-as ;

: semver-inc-major ( semver -- semver )
    dup prerelease>> [
        [ 1 + ] change-major
        0 >>minor
        0 >>patch
        "" >>prerelease
        "" >>build
    ] [
        drop
        "" >>prerelease
        "" >>build
    ] if-empty ;

: semver-inc-minor ( semver -- semver )
    dup prerelease>> [
        [ 1 + ] change-minor
        0 >>patch
        "" >>prerelease
        "" >>build
    ] [
        drop
        "" >>prerelease
        "" >>build
    ] if-empty ;

: semver-inc-patch ( semver -- semver )
    dup prerelease>> [
        [ 1 + ] change-patch
        0 >>patch
        "" >>prerelease
        "" >>build
    ] [
        drop
        "" >>prerelease
        "" >>build
    ] if-empty ;

: ?inc-string ( str -- str' )
    string>number 1 + number>string ;

: semver-inc-prerelease ( semver -- semver )
    dup prerelease>> [
        "0"
    ] [
        "." split
        dup [ string>number ] find-last [
            over [ ?inc-string ] change-nth
            "." join
        ] [
            2drop "dev.0"
        ] if
    ] if-empty >>prerelease
    "" >>build ;

: semver-inc-prerelease-id ( semver id -- semver )
    over prerelease>> [
        "0" "." glue
    ] [
        2dup swap head? [
            "." split
            dup [ string>number ] find-last [
                over [ ?inc-string ] change-nth
                "." join nip
            ] [
                2drop "0" "." glue
            ] if
        ] [
            drop "0" "." glue
        ] if
    ] if-empty >>prerelease
    "" >>build ;

: semver-inc-prepatch ( semver -- semver )
    [ 1 + ] change-patch
    "dev.0" >>prerelease
    "" >>build ;

: semver-inc-preminor ( semver -- semver )
    [ 1 + ] change-minor
    0 >>patch
    "dev.0" >>prerelease
    "" >>build ;

: semver-inc-premajor ( semver -- semver )
    [ 1 + ] change-major
    0 >>minor
    0 >>patch
    "dev.0" >>prerelease
    "" >>build ;

GENERIC: lower-range ( obj -- str )

M: string lower-range ( obj -- semver )
    parse-semver semver>string ">=" prepend ;

M: array lower-range ( obj -- semver )
    parse-semver semver>string ">=" prepend ;

! rule:.hide should hide it
EBNF: parse-range [=[
    logical-or = [\s\t]*  '||'  [\s\t]* => [[ second ]]
    range      = hyphen | simple ([\s\t]* simple  => [[ second ]] )*  => [[ first2 swap prefix ]] | "" => [[ ]]
    hyphen     = partial:p1 [\s\t]*  '-':t  [\s\t]*  partial:p2 => [[ p1 t  p2 3array ]]
    simple     = primitive | partial | tilde | caret
    primitive  = ( '~>' | '>=' | '<=' | '>' | '<' | '=' ) [\s\t]* => [[ first2 drop ]] partial
    partial    = xr ( '.' xr ( '.' xr qualifier? )? )? => [[ flatten concat ]]
    xr         = 'x' | 'X' | "*" | nr
    nr         = [0-9]+ => [[ string>number number>string ]]
    tilde      = '~'  [\s\t]*  partial => [[ first3 nip 2array ]]
    caret      = '^'  [\s\t]*  partial => [[ first3 nip 2array ]]
    qualifier  = ( '-' pre )? ( '+' build )?
    pre        = parts
    build      = parts
    parts      = part ( '.' part )*
    part       = nr | [-0-9A-Za-z]+ => [[ >string ]]
    range-set  = range ( logical-or range )* => [[ first2 swap prefix ]]
]=]


! ^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$
