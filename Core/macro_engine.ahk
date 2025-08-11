#Requires AutoHotkey v2.0

; Initialize macro engine
InitializeMacroEngine() {
    global MacroTimers := Map()
}

; Show a temporary tooltip
ShowTooltip(message, duration := 2000) {
    ToolTip(message)
    SetTimer(() => ToolTip(), -duration)  ; Hide after duration ms
}

; Start a macro for a profile
StartMacro(profileName) {
    global Profiles, MacroTimers
    
    if !Profiles.Has(profileName) {
        ShowTooltip("Profile not found: " . profileName)
        return false
    }

    profile := Profiles[profileName]
    
    ; Check if window exists and get its position
    targetWindow := profile.WindowTitle . " " . profile.WindowClass
    if !WinExist(targetWindow) {
        ShowTooltip("Target window not found: " . targetWindow)
        return false
    }

    ; Get window position for relative coordinates
    WinGetPos(&winX, &winY, &winWidth, &winHeight, targetWindow)
    ShowTooltip("Target window found at: " . winX . "," . winY . " size: " . winWidth . "x" . winHeight)

    ; Stop if already running
    if profile.Enabled {
        ShowTooltip("Macro already running for " . profileName)
        return true
    }

    ; Store start time in the profile
    profile.StartTime := A_TickCount

    ; Create timer function
    timerFunc := MacroLoop.Bind(profile)
    SetTimer(timerFunc, profile.Interval)
    
    MacroTimers[profileName] := timerFunc
    profile.Enabled := true
    
    ShowTooltip("Started macro for " . profileName . "`nInterval: " . profile.Interval . "ms")
    return true
}

; Stop a macro for a profile
StopMacro(profileName) {
    global Profiles, MacroTimers
    
    if !Profiles.Has(profileName)
        return false

    profile := Profiles[profileName]
    
    if !profile.Enabled
        return true

    ; Stop the timer first
    if MacroTimers.Has(profileName) {
        SetTimer(MacroTimers[profileName], 0)
        MacroTimers.Delete(profileName)
    }

    ; Calculate run time
    runTime := A_TickCount - profile.StartTime

    ; Update state
    profile.Enabled := false
    
    ; Clear any remaining tooltips
    SetTimer(() => ToolTip(), -1)
    
    ; Show stop message
    ShowTooltip("Stopped macro for " . profileName . "`nTotal time: " . FormatDuration(runTime))
    return true
}

; Detect if a window is a game window
IsGameWindow(windowClass) {
    gameClasses := ["WINDOWSCLIENT", "UnityWndClass", "RobloxApp", "DirectUIHWND"]
    for class in gameClasses {
        if InStr(windowClass, class)
            return true
    }
    return false
}

; Send mouse input using Windows API
SendMouseInput(x, y, flags) {
    ; MOUSEEVENTF constants
    MOUSEEVENTF_MOVE := 0x0001
    MOUSEEVENTF_LEFTDOWN := 0x0002
    MOUSEEVENTF_LEFTUP := 0x0004
    MOUSEEVENTF_ABSOLUTE := 0x8000
    
    ; Convert coordinates to normalized absolute coordinates (0-65535)
    normalizedX := Floor((x * 65535) / A_ScreenWidth)
    normalizedY := Floor((y * 65535) / A_ScreenHeight)
    
    ; Create input structure
    size := 28  ; Size of INPUT structure
    input := Buffer(size, 0)
    
    ; Set input type to mouse (0)
    NumPut("UInt", 0, input, 0)
    
    ; Set absolute coordinates and flags
    NumPut("UInt", flags | MOUSEEVENTF_ABSOLUTE, input, 8)
    NumPut("UInt", normalizedX, input, 12)
    NumPut("UInt", normalizedY, input, 16)
    
    ; Send input
    DllCall("SendInput", "UInt", 1, "Ptr", input, "Int", size)
}

; Click at coordinates using direct input (for game windows)
GameClick(x, y, hwnd) {
    try {
        ; Store current mouse position
        MouseGetPos(&oldX, &oldY)
        
        ; Constants
        MOUSEEVENTF_MOVE := 0x0001
        MOUSEEVENTF_LEFTDOWN := 0x0002
        MOUSEEVENTF_LEFTUP := 0x0004
        
        ; Move cursor
        SendMouseInput(x, y, MOUSEEVENTF_MOVE)
        Sleep(10)  ; Small delay for stability
        
        ; Send click down
        SendMouseInput(x, y, MOUSEEVENTF_LEFTDOWN)
        Sleep(10)  ; Small delay between down and up
        
        ; Send click up
        SendMouseInput(x, y, MOUSEEVENTF_LEFTUP)
        
        ; Restore cursor position
        DllCall("SetCursorPos", "int", oldX, "int", oldY)
    } catch as err {
        throw Error("Game click failed: " . err.Message)
    }
}

; Click at coordinates using PostMessage (for regular windows)
WindowClick(x, y, hwnd) {
    try {
        ; Move cursor (WM_MOUSEMOVE = 0x0200)
        PostMessage(0x0200, 0, (y << 16) | x, , "ahk_id " . hwnd)
        ; Left button down (WM_LBUTTONDOWN = 0x0201)
        PostMessage(0x0201, 1, (y << 16) | x, , "ahk_id " . hwnd)
        ; Left button up (WM_LBUTTONUP = 0x0202)
        PostMessage(0x0202, 0, (y << 16) | x, , "ahk_id " . hwnd)
    } catch as err {
        throw Error("Window click failed: " . err.Message)
    }
}

; Macro execution loop
MacroLoop(profile) {
    targetWindow := profile.WindowTitle . " " . profile.WindowClass
    
    ; Check if window exists and get its position
    if !WinExist(targetWindow) {
        StopMacro(profile.Name)
        ShowTooltip("Target window no longer exists!")
        return
    }

    ; Get window position for relative coordinates
    WinGetPos(&winX, &winY, &winWidth, &winHeight, targetWindow)
    
    ; Convert MacroType=2 to "Click" for compatibility
    macroType := profile.MacroType = "2" ? "Click" : profile.MacroType

    if (macroType = "Click") {
        try {
            ; Calculate click coordinates relative to window
            x := Integer(profile.Coordinates[1])
            y := Integer(profile.Coordinates[2])
            
            ; Ensure coordinates are within window bounds
            if (x < 0 || x > winWidth || y < 0 || y > winHeight) {
                ShowTooltip("Click coordinates (" . x . "," . y . ") are outside window bounds!")
                StopMacro(profile.Name)
                return
            }

            ; Show where we're clicking
            ShowTooltip("Background clicking at: " . x . "," . y)
            
            ; Get window handle
            hwnd := WinExist(targetWindow)
            
            ; Convert coordinates to screen coordinates
            x += winX
            y += winY
            
            ; Use appropriate click method based on window type
            if IsGameWindow(profile.WindowClass)
                GameClick(x, y, hwnd)
            else
                WindowClick(x, y, hwnd)
            
            ShowTooltip("Click completed")
        } catch as err {
            ShowTooltip("Click operation failed: " . err.Message)
            StopMacro(profile.Name)
        }
    }
    else if (macroType = "Keys") {
        try {
            ShowTooltip("Sending keys: " . profile.Keys)
            
            ; Always use ControlSend for background operation
            ControlSend(
                profile.Keys,
                ,  ; Control (empty for active control)
                targetWindow,
                ,  ; No activation needed
                "NA"  ; No activation flag
            )
            
            ShowTooltip("Key send completed")
        } catch as err {
            ShowTooltip("Key send failed: " . err.Message)
            StopMacro(profile.Name)
        }
    }
}

; Toggle macro state
ToggleMacro(profileName) {
    global Profiles
    
    if !Profiles.Has(profileName)
        return false

    profile := Profiles[profileName]
    
    if profile.Enabled
        return StopMacro(profileName)
    else
        return StartMacro(profileName)
} 