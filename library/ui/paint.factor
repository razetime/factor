! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays freetype gadgets-layouts generic hashtables
io kernel lists math namespaces opengl sequences strings
styles vectors ;
IN: gadgets

SYMBOL: clip

: init-gl ( dim -- )
    { 1.0 0.0 0.0 1.0 } gl-color
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    GL_MODELVIEW glMatrixMode
    glLoadIdentity
    { 0 0 0 } over <rect> clip set
    dup first2 0 0 2swap glViewport
    0 swap first2 0 gluOrtho2D
    GL_SMOOTH glShadeModel
    GL_BLEND glEnable
    GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
    GL_SCISSOR_TEST glEnable
    GL_MODELVIEW glMatrixMode
    1.0 1.0 1.0 1.0 glClearColor
    GL_COLOR_BUFFER_BIT glClear ;

GENERIC: draw-gadget* ( gadget -- )

M: gadget draw-gadget* ( gadget -- ) drop ;

GENERIC: draw-interior ( gadget interior -- )

GENERIC: draw-boundary ( gadget boundary -- )

: visible-children ( gadget -- seq ) clip get swap children-on ;

DEFER: draw-gadget

: (draw-gadget) ( gadget -- )
    dup rect-loc translate [
        gl-translate
        dup dup gadget-interior draw-interior
        dup dup gadget-boundary draw-boundary
        draw-gadget*
    ] keep vneg gl-translate ;

: gl-set-clip ( loc dim -- )
    dup first2 1+ >r >r
    over second swap second + world get rect-dim second
    swap - >r first r> r> r> glScissor ;

: do-clip ( gadget -- )
    >absolute clip [ rect-intersect dup ] change
    dup rect-loc swap rect-dim gl-set-clip ;

: draw-gadget ( gadget -- )
    clip get over inside? [
        [
            dup do-clip
            dup (draw-gadget)
            dup visible-children [ draw-gadget ] each
        ] with-scope
    ] when drop ;

: draw-world ( world -- )
    [
        dup rect-dim init-gl dup world set draw-gadget
    ] with-scope ;

! Pen paint properties
M: f draw-interior 2drop ;
M: f draw-boundary 2drop ;

! Solid fill/border
TUPLE: solid color ;

! Solid pen
M: solid draw-interior
    solid-color gl-color rect-dim gl-fill-rect ;

M: solid draw-boundary
    solid-color gl-color rect-dim gl-rect ;

! Gradient pen
TUPLE: gradient colors ;

M: gradient draw-interior ( gadget gradient -- )
    over gadget-orientation swap gradient-colors rot rect-dim
    gl-gradient ;

! Polygon pen
TUPLE: polygon color points ;

: draw-polygon ( polygon quot -- )
    >r dup polygon-color gl-color polygon-points r> each ; inline

M: polygon draw-boundary ( gadget polygon -- )
    [ gl-poly ] draw-polygon drop ;

M: polygon draw-interior ( gadget polygon -- )
    [ gl-fill-poly ] draw-polygon drop ;

: arrow-up    { { { 3 0 0 } { 6 6 0 } { 0 6 0 } } } ;
: arrow-right { { { 0 0 0 } { 6 3 0 } { 0 6 0 } } } ;
: arrow-down  { { { 0 0 0 } { 6 0 0 } { 3 6 0 } } } ;
: arrow-left  { { { 0 3 0 } { 6 0 0 } { 6 6 0 } } } ;

: arrow-right|
    { { { 6 0 0 } { 6 6 0 } } } arrow-right append ;

: arrow-|left
    { { { 1 0 0 } { 1 6 0 } } } arrow-left append ;

: <polygon-gadget> ( color points -- gadget )
    dup { 0 0 0 } [ max-dim vmax ] reduce
    >r <polygon> <gadget> r> over set-rect-dim
    [ set-gadget-interior ] keep ;
