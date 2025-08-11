#Requires AutoHotkey v2.0

; Initialize utils module
InitializeUtils() {
    ; Any initialization needed for utils
}

; Create a new profile from template
CreateProfile(profileName, windowTitle := "", windowClass := "", coordinates := "150,150", interval := 1000, hotkey := "\") {
    global AppName
    
    ; Validate profile name
    if !profileName {
        ShowError("Profile name is required")
        return false
    }
    
    ; Create profiles directory if it doesn't exist
    if !DirExist("profiles")
        DirCreate("profiles")
    
    ; Check if profile already exists
    profilePath := "profiles/" . profileName . ".ini"
    if FileExist(profilePath) {
        ShowError("Profile already exists: " . profileName)
        return false
    }
    
    ; If no window info provided, try to get from active window
    if (!windowTitle || !windowClass) {
        activeHwnd := WinExist("A")
        if activeHwnd {
            windowTitle := WinGetTitle(activeHwnd)
            windowClass := "ahk_class " . WinGetClass(activeHwnd)
        } else {
            windowTitle := "Chrome"
            windowClass := "ahk_class Chrome_WidgetWin_1"
        }
    }
    
    ; Create profile content
    profileContent := "
(
[Profile]
Name=" . profileName . "
WindowTitle=" . windowTitle . "
WindowClass=" . windowClass . "
MacroType=2
Interval=" . interval . "
Hotkey=" . hotkey . "
Coordinates=" . coordinates . "
Keys=
)"
    
    ; Write profile file
    try {
        FileAppend(profileContent, profilePath)
        ShowInfo("Created new profile: " . profileName . "`nLocation: " . profilePath)
        return true
    } catch as err {
        ShowError("Failed to create profile: " . err.Message)
        return false
    }
}

; Get list of all open windows
GetOpenWindows() {
    windows := []
    DetectHiddenWindows(false)  ; Only visible windows
    windowIds := WinGetList()
    
    for windowId in windowIds {
        ; Skip windows without titles
        title := WinGetTitle(windowId)
        if !title
            continue
            
        ; Get window info
        class := WinGetClass(windowId)
        process := WinGetProcessName(windowId)
        
        ; Add to list if it's a valid window
        if (title && class && process) {
            windowInfo := Map()
            windowInfo["title"] := title
            windowInfo["class"] := "ahk_class " . class
            windowInfo["process"] := "ahk_exe " . process
            windowInfo["id"] := windowId
            windows.Push(windowInfo)
        }
    }
    
    return windows
}

; Read an INI file section
ReadIniSection(filename, section) {
    result := Map()
    if !FileExist(filename)
        return result
    
    try {
        sections := IniRead(filename)
        if !InStr(sections, section)
            return result
            
        sectionContent := IniRead(filename, section)
        Loop Parse, sectionContent, "`n", "`r" {
            key_value := StrSplit(A_LoopField, "=")
            if (key_value.Length = 2)
                result[key_value[1]] := key_value[2]
        }
    } catch as err {
        ShowError("Failed to read INI file: " . err.Message)
    }
    return result
}

; Write an INI section
WriteIniSection(filename, section, data) {
    if Type(data) != "Map"
        return false
    
    for key, value in data
        IniWrite(value, filename, section, key)
    return true
}

; Show an error message box
ShowError(message) {
    MsgBox(message, AppName . " - Error", 16)  ; 16 = Icon Hand (stop/error)
}

; Show an info message box
ShowInfo(message) {
    MsgBox(message, AppName, 64)  ; 64 = Icon Asterisk (information)
}

; Validate window exists
IsWindowValid(winTitle) {
    return WinExist(winTitle) ? true : false
}

; Format time duration for display
FormatDuration(ms) {
    if (ms < 1000)
        return ms . "ms"
    else if (ms < 60000)
        return Format("{:.1f}s", ms/1000)
    else
        return Format("{:.1f}m", ms/60000)
} 