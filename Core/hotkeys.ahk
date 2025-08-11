#Requires AutoHotkey v2.0

; Initialize hotkeys module
InitializeHotkeys() {
    global RegisteredHotkeys := Map()
    RegisterProfileHotkeys()
}

; Register hotkeys for all profiles
RegisterProfileHotkeys() {
    global Profiles
    
    for profileName, profile in Profiles {
        if profile.Hotkey
            RegisterProfileHotkey(profile)
    }
}

; Register a hotkey for a specific profile
RegisterProfileHotkey(profile) {
    global RegisteredHotkeys
    
    if !profile.Hotkey
        return false

    ; Unregister existing hotkey if any
    UnregisterProfileHotkey(profile.Name)
    
    ; Create the hotkey
    try {
        hotkeyFunc := ProfileHotkeyHandler.Bind(profile)
        Hotkey(profile.Hotkey, hotkeyFunc, "On")  ; Ensure hotkey is enabled
        RegisteredHotkeys[profile.Name] := {
            key: profile.Hotkey,
            func: hotkeyFunc
        }
        ToolTip("Registered hotkey " . profile.Hotkey . " for " . profile.Name)
        SetTimer(() => ToolTip(), -1000)
        return true
    } catch Error as e {
        ShowError("Failed to register hotkey for " . profile.Name . ": " . e.Message)
        return false
    }
}

; Unregister a profile's hotkey
UnregisterProfileHotkey(profileName) {
    global RegisteredHotkeys
    
    if !RegisteredHotkeys.Has(profileName)
        return false

    try {
        Hotkey(RegisteredHotkeys[profileName].key, "Off")
        RegisteredHotkeys.Delete(profileName)
        return true
    } catch Error as e {
        ShowError("Failed to unregister hotkey for " . profileName . ": " . e.Message)
        return false
    }
}

; Handler for profile hotkeys
ProfileHotkeyHandler(profile, *) {
    global Profiles
    
    ; Get current state
    isEnabled := Profiles[profile.Name].Enabled
    
    ; Toggle the macro
    if (isEnabled) {
        ToolTip("Stopping macro for " . profile.Name)
        StopMacro(profile.Name)
    } else {
        ToolTip("Starting macro for " . profile.Name)
        StartMacro(profile.Name)
    }
    SetTimer(() => ToolTip(), -1000)
}

; Update a profile's hotkey
UpdateProfileHotkey(profileName, newHotkey) {
    global Profiles
    
    if !Profiles.Has(profileName)
        return false

    profile := Profiles[profileName]
    oldHotkey := profile.Hotkey
    
    ; Remove old hotkey
    if oldHotkey
        UnregisterProfileHotkey(profileName)
    
    ; Set new hotkey
    profile.Hotkey := newHotkey
    
    ; Register new hotkey if provided
    if newHotkey {
        success := RegisterProfileHotkey(profile)
        if success {
            ToolTip("Updated hotkey to " . newHotkey . " for " . profileName)
            SetTimer(() => ToolTip(), -1000)
        }
        return success
    }
    
    return true
} 