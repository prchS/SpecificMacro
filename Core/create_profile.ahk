#Requires AutoHotkey v2.0
#SingleInstance Force

; Include utils
#Include utils.ahk

; Initialize
global AppName := "Profile Creator"

; Create GUI
myGui := Gui()
myGui.SetFont("s10", "Segoe UI")

; Add controls
myGui.Add("Text",, "Profile Name:")
nameEdit := myGui.Add("Edit", "w300")

myGui.Add("Text",, "Window Title (leave blank for active window):")
titleEdit := myGui.Add("Edit", "w300")

myGui.Add("Text",, "Window Class (leave blank for active window):")
classEdit := myGui.Add("Edit", "w300")

myGui.Add("Text",, "Click Coordinates (x,y):")
coordEdit := myGui.Add("Edit", "w300", "150,150")

myGui.Add("Text",, "Click Interval (ms):")
intervalEdit := myGui.Add("Edit", "w300", "1000")

myGui.Add("Text",, "Hotkey:")
hotkeyEdit := myGui.Add("Edit", "w300", "\")

; Add buttons
myGui.Add("Button", "w150", "Create Profile").OnEvent("Click", CreateNewProfile)
myGui.Add("Button", "x+10 w150", "Get Active Window").OnEvent("Click", GetActiveWindow)

; Show GUI
myGui.Title := "Create New Profile"
myGui.Show()

; Create profile button handler
CreateNewProfile(*) {
    global nameEdit, titleEdit, classEdit, coordEdit, intervalEdit, hotkeyEdit
    
    ; Get values
    profileName := nameEdit.Value
    windowTitle := titleEdit.Value
    windowClass := classEdit.Value
    coordinates := coordEdit.Value
    interval := intervalEdit.Value
    hotkey := hotkeyEdit.Value
    
    ; Create profile
    if CreateProfile(profileName, windowTitle, windowClass, coordinates, interval, hotkey) {
        ; Clear form on success
        nameEdit.Value := ""
        titleEdit.Value := ""
        classEdit.Value := ""
        coordEdit.Value := "150,150"
        intervalEdit.Value := "1000"
        hotkeyEdit.Value := "\"
    }
}

; Get active window button handler
GetActiveWindow(*) {
    global titleEdit, classEdit
    
    activeHwnd := WinExist("A")
    if activeHwnd {
        titleEdit.Value := WinGetTitle(activeHwnd)
        classEdit.Value := "ahk_class " . WinGetClass(activeHwnd)
    } else {
        ShowError("No active window found!")
    }
}

; Keep script running
OnMessage(0x112, WM_SYSCOMMAND) 