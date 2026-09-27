# Wine patches

These patches are applied on top of the upstream Wine source by
`scripts/build-wine.sh`. They are derived from Wine and licensed under the
**GNU LGPL 2.1 or later** (see `COPYING.LIB`), like Wine itself.

| Patch | Problem | Fix |
|---|---|---|
| `0001-winex11-ignore-stale-mouse-move-resize.patch` | Qt posts a second `SC_DRAGMOVE` after the mouse button is released. Wine forwarded it to the window manager as `_NET_WM_MOVERESIZE`, so the window kept following the pointer until the next click. | In `move_resize_window`, re-check the real X pointer state and ignore mouse-driven move/resize requests when no button is pressed. Keyboard moves are unaffected. |
