#Requires AutoHotkey v2.0
#SingleInstance Force

; Vowen Volume Ducker (v2 — stateless)
;
; Drops system volume to DUCK_LEVEL when Ctrl+Shift is pressed (start dictation).
; Restores the previously captured volume on the next Ctrl+Shift press (stop).
;
; Stateless design: every press reads the CURRENT system volume and decides
; duck-vs-restore from that, not from an internal flag. This makes it
; robust against phantom events, Set-Volume failures during early boot, or
; anything else that could drift an internal "isDucked" flag out of sync
; with reality.
;
; Uses InputHook in Visible / non-intercepting mode — keys are NOT swallowed,
; so Vowen continues to receive Ctrl+Shift exactly as typed.

; ==== CONFIG ====
DUCK_LEVEL := 10
TOLERANCE  := 1.5  ; current volume within ±this of DUCK_LEVEL counts as "ducked"

; ==== STATE ====
; -1 is the "not yet captured" sentinel; gets replaced with the real current
; volume either at startup or before the first duck, whichever comes first.
global g_PreviousVolume := -1
global g_CtrlHeld := false
global g_ShiftHeld := false
global g_Dirty := false

; Capture startup volume so the very first restore has a sensible target,
; even if the user double-taps Ctrl+Shift as their first action.
try g_PreviousVolume := SoundGetVolume()

; ==== CORE ====
ToggleDuck() {
    global g_PreviousVolume, DUCK_LEVEL, TOLERANCE
    currentVol := SoundGetVolume()
    atDuckLevel := Abs(currentVol - DUCK_LEVEL) < TOLERANCE

    if (atDuckLevel && g_PreviousVolume > DUCK_LEVEL + TOLERANCE) {
        ; Currently ducked with a valid previous → restore
        SoundSetVolume(g_PreviousVolume)
    } else {
        ; Not ducked (or no valid previous) → duck
        if (currentVol > DUCK_LEVEL + TOLERANCE) {
            g_PreviousVolume := currentVol  ; save only if current is meaningfully above duck
        }
        SoundSetVolume(DUCK_LEVEL)
    }
}

IsCtrl(vk) {
    return (vk = 0x11 || vk = 0xA2 || vk = 0xA3)
}
IsShift(vk) {
    return (vk = 0x10 || vk = 0xA0 || vk = 0xA1)
}

OnDownCB(ih, vk, sc) {
    global g_CtrlHeld, g_ShiftHeld, g_Dirty
    if (IsCtrl(vk)) {
        if (!g_CtrlHeld) {
            g_Dirty := false
        }
        g_CtrlHeld := true
    } else if (IsShift(vk)) {
        if (!g_ShiftHeld) {
            g_Dirty := false
        }
        g_ShiftHeld := true
    } else {
        if (g_CtrlHeld && g_ShiftHeld) {
            g_Dirty := true
        }
    }
}

OnUpCB(ih, vk, sc) {
    global g_CtrlHeld, g_ShiftHeld, g_Dirty

    if (!IsCtrl(vk) && !IsShift(vk)) {
        return
    }

    if (g_CtrlHeld && g_ShiftHeld && !g_Dirty) {
        ToggleDuck()
        g_Dirty := true
    }

    if (IsCtrl(vk)) {
        g_CtrlHeld := false
    } else {
        g_ShiftHeld := false
    }

    if (!g_CtrlHeld && !g_ShiftHeld) {
        g_Dirty := false
    }
}

; ==== INPUT HOOK (observer, non-blocking) ====
ih := InputHook("V")          ; V = Visible — keys are NOT swallowed
ih.KeyOpt("{All}", "N")       ; N = Notify — fire OnKeyDown/Up for every key
ih.OnKeyDown := OnDownCB
ih.OnKeyUp := OnUpCB
ih.Start()

Persistent
