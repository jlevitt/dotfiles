!`::
active_window := WinExist("A")
SetTitleMatchMode, 1
GroupAdd, Zoom, Zoom
GroupAdd, Zoom, Meeting
WinActivate, ahk_group Zoom
Send, !a
WinActivate, ahk_id %active_window%
return

PrintScreen::
Run SnippingTool
Sleep, 200
Send, ^n
return
