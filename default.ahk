#Requires AutoHotkey v2.0
#SingleInstance Force

; Alt+` : toggle mute in Zoom without losing focus
!`::
{
    active_window := WinExist("A")
    SetTitleMatchMode(1)
    GroupAdd("Zoom", "Zoom")
    GroupAdd("Zoom", "Meeting")
    WinActivate("ahk_group Zoom")
    Send("!a")
    if active_window
        WinActivate("ahk_id " active_window)
}

; PrintScreen : open Snipping Tool and start a new capture
PrintScreen::
{
    Run("SnippingTool")
    Sleep(200)
    Send("^n")
}

; --- Relisten media keys ---
; relisten.net plays through the Web Audio graph while its <audio> element
; stays paused, so Chrome never dispatches a "pause" media session action to
; the page - the OS pause is structurally unavailable. Its own Space / Left /
; Right shortcuts do work, so translate the media keys into those.
;
; Two things that are easy to get wrong here:
;   * DetectHiddenWindows must be ON. A Chrome window parked on another
;     virtual desktop is DWM shell-cloaked, and AHK's default matching skips
;     cloaked windows, so WinExist returns 0 and the key silently falls
;     through to nothing.
;   * ControlSend does not work. Chrome ignores synthesized keystrokes
;     without real focus, so the window genuinely has to be activated. If it
;     lives on another virtual desktop, expect a desktop flip and back.

RELISTEN_DEBUG := false   ; true = tooltips showing which branch was taken

$Media_Play_Pause:: RelistenRelay("{Space}", "{Media_Play_Pause}")
$Media_Next::       RelistenRelay("{Right}", "{Media_Next}")
$Media_Prev::       RelistenRelay("{Left}",  "{Media_Prev}")

RelistenRelay(siteKey, rawKey) {
    SetTitleMatchMode(2)
    DetectHiddenWindows(true)          ; see windows on other virtual desktops

    hwnd := WinExist("Relisten ahk_exe chrome.exe")
    if !hwnd {
        Blip("no Relisten window - passing " rawKey " through")
        Send(rawKey)                    ; let Spotify etc. have the key
        return
    }

    prev := WinExist("A")               ; remember what had focus
    if (hwnd = prev) {
        Send(siteKey)                   ; already focused, nothing to restore
        return
    }

    WinActivate(hwnd)
    if !WinWaitActive(hwnd, , 1) {
        Blip("could not activate the Relisten window")
        return
    }
    Send(siteKey)
    if prev
        WinActivate("ahk_id " prev)
}

Blip(msg) {
    global RELISTEN_DEBUG
    if !RELISTEN_DEBUG
        return
    ToolTip(msg)
    SetTimer(() => ToolTip(), -2500)
}

; Ctrl+Alt+R : list every Chrome window AHK can see, cloaked ones included
^!r:: {
    SetTitleMatchMode(2)
    DetectHiddenWindows(true)
    out := ""
    for hwnd in WinGetList("ahk_exe chrome.exe") {
        t := WinGetTitle(hwnd)
        if t != ""
            out .= hwnd ": " t "`n"
    }
    MsgBox(out = "" ? "No Chrome windows found." : out, "Chrome windows AHK can see")
}
