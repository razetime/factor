REQUIRES: core/ui/opengl core/ui/freetype ;

PROVIDE: core/ui
{ +files+ {
    "timers.factor"
    "models.factor"
    "backend.factor"
    "gadgets.factor"
    "layouts.factor"
    "hierarchy.factor"
    "gadgets/grids.factor"
    "gadgets/frames.factor"
    "world.factor"
    "text.factor"
    "paint.factor"
    "gestures.factor"
    "commands.factor"
    "windows.factor"
    "gadgets/controls.factor"
    "gadgets/grid-lines.factor"
    "gadgets/theme.factor"
    "gadgets/labels.factor"
    "gadgets/borders.factor"
    "gadgets/buttons.factor"
    "gadgets/sliders.factor"
    "gadgets/viewports.factor"
    "gadgets/scrolling.factor"
    "gadgets/tracks.factor"
    "gadgets/incremental.factor"
    "gadgets/paragraphs.factor"
    "gadgets/panes.factor"
    "gadgets/labelled-gadget.factor"
    "gadgets/books.factor"
    "gadgets/outliner.factor"
    "gadgets/menus.factor"
    "gadgets/presentations.factor"
    "gadgets/lists.factor"
    "text/document.factor"
    "text/elements.factor"
    "text/editor.factor"
    "text/commands.factor"
    "text/interactor.factor"
    "debugger.factor"
    "ui.factor"
    "tools/tools.factor"
    "tools/messages.factor"
    "tools/listener.factor"
    "tools/walker.factor"
    "tools/browser.factor"
    "tools/help.factor"
    "tools/dataflow.factor"
    "tools/workspace.factor"
    "tools/search.factor"
    "tools/operations.factor"
    "text/editor.facts"
} }
{ +tests+ {
    "test/editor.factor"
    "test/gadgets.factor"
    "test/models.factor"
    "test/document.factor"
    "test/listener.factor"
    "test/lists.factor"
    "test/rectangles.factor"
    "test/commands.factor"
    "test/panes.factor"
    "test/presentations.factor"
    "test/scrolling.factor"
    "test/search.factor"
    "test/sliders.factor"
    "test/titled-gadget.factor"
} } ;
