#Requires AutoHotkey v2.0
#SingleInstance Force

; Vowen Volume Ducker
; Drops system volume to DUCK_LEVEL when Ctrl+Shift is pressed (start dictation).
; Restores the previous volume on the next Ctrl+Shift press (stop dictation).
;
; Uses InputHook in VISIBLE / non-intercepting mode — keys are NOT swallowed,
; so Vowen continues to receive Ctrl+Shift exactly as the user typed it.
; This script is a silent observer only.

; ==== CONFIG ====
DUCK_LEVEL := 10

; ==== STATE ====
global g_IsDucked := false
global g_PreviousVolume := 0
global g_CtrlHeld := false
global g_ShiftHeld := false
global g_Dirty := false  ; set when a non-modifier key is pressed while Ctrl+Shift held

; ==== CORE ====
ToggleDuck() {
    global g_IsDucked, g_PreviousVolume, DUCK_LEVEL
    if g_IsDucked {
        SoundSetVolume(g_PreviousVolume)
        g_IsDucked := false
    } else {
        g_PreviousVolume := SoundGetVolume()
        SoundSetVolume(DUCK_LEVEL)
        g_IsDucked := true
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
