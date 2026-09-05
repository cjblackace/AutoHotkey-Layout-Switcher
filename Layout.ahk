#Requires AutoHotkey v2.0
#SingleInstance Force

EN := 0x0409
RU := 0x0419
JP := 0x0411


GetLayout() {
    hwnd := WinExist("A")

    threadID := DllCall(
        "GetWindowThreadProcessId",
        "Ptr", hwnd,
        "UInt*", 0
    )

    hkl := DllCall(
        "GetKeyboardLayout",
        "UInt", threadID,
        "Ptr"
    )

    return hkl & 0xFFFF
}


; Переключает штатным Win+Space,
; пока не будет достигнут нужный язык.
SwitchToLayout(target) {
    Loop 5 {
        current := GetLayout()

        if (current = target)
            return true

        SendEvent("#{Space}")
        Sleep(180)
    }

    return false
}


; ==========================================
; LEFT SHIFT + LEFT ALT
; Только RU <-> EN
; ==========================================

<+LAlt::
{
    current := GetLayout()

    if (current = RU)
        SwitchToLayout(EN)
    else
        SwitchToLayout(RU)
}


; ==========================================
; LEFT CTRL + LEFT SHIFT
; Japanese -> Hiragana
; ==========================================

<^LShift::
{
    if SwitchToLayout(JP) {
        Sleep(200)

        ; Штатная команда Microsoft Japanese IME:
        ; переход в Hiragana
        SendEvent("{Ctrl down}{CapsLock}{Ctrl up}")
    }
}
