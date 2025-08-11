#Requires AutoHotkey v2.0
#SingleInstance Force

; Global variables
global AppName := "SpecificMacro"
global Version := "1.0.0"
global ProfilesDir := A_ScriptDir . "\..\profiles"
global ActiveProfile := ""
global Profiles := {}

; Include all modules
#Include ../core/utils.ahk
#Include ../core/profile.ahk
#Include ../core/macro_engine.ahk
#Include ../core/gui.ahk
#Include ../core/hotkeys.ahk

; Ensure profiles directory exists
if !DirExist(ProfilesDir)
    DirCreate(ProfilesDir)

; Initialize modules
InitializeUtils()
InitializeProfiles()
InitializeMacroEngine()
InitializeHotkeys()
InitializeGUI()

; Show the main GUI
ShowMainGUI()

return  ; End of auto-execute section 