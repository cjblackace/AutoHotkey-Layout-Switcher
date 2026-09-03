#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook

; ==========================================
; Языки
; ==========================================

EN := 0x0409
RU := 0x0419
JP := 0x0411


; ==========================================
; Получить текущий язык активного окна
; ==========================================

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


; ==========================================
; Переключить раскладку
; ==========================================

SetLayout(localeId) {

    static SPI_SETDEFAULTINPUTLANG := 0x005A
    static SPIF_SENDWININICHANGE := 0x0002

    static WM_INPUTLANGCHANGEREQUEST := 0x0050
    static WM_INPUTLANGCHANGE := 0x0051

    static KLF_ACTIVATE := 0x00000001

    klid := Format("{:08X}", localeId)

    hkl := DllCall(
        "LoadKeyboardLayout",
        "Str", klid,
        "UInt", KLF_ACTIVATE,
        "Ptr"
    )

    DllCall(
        "SystemParametersInfo",
        "UInt", SPI_SETDEFAULTINPUTLANG,
        "UInt", 0,
        "UPtr", hkl,
        "UInt", SPIF_SENDWININICHANGE
    )

    for hwnd in WinGetList() {
        try {
            PostMessage(
                WM_INPUTLANGCHANGEREQUEST,
                0,
                hkl,
                ,
                "ahk_id " hwnd
            )

            PostMessage(
                WM_INPUTLANGCHANGE,
                0,
                hkl,
                ,
                "ahk_id " hwnd
            )
        }
    }
}


; ==========================================
; LEFT SHIFT + LEFT ALT
; Только RU <-> EN
; ==========================================

<+LAlt::
{
    current := GetLayout()

    if (current = RU)
        SetLayout(EN)
    else
        SetLayout(RU)
}


; ==========================================
; LEFT CTRL + LEFT SHIFT
; Japanese -> Hiragana
; ==========================================

<^LShift::
{
    SetLayout(JP)

    ; Дождаться активации Japanese IME
    Sleep(250)

    ; Ctrl + CapsLock =
    ; штатная команда перехода в Hiragana
    SendEvent("{Ctrl down}{CapsLock}{Ctrl up}")
}
