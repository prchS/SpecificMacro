#Requires AutoHotkey v2.0

; Profile class definition
class MacroProfile {
    Name := ""
    WindowTitle := ""
    WindowClass := ""
    MacroType := "Click"    ; Click or Keys
    Interval := 1000        ; Default 1 second
    Hotkey := ""           ; Activation hotkey
    Enabled := false       ; Is macro active
    Coordinates := [0, 0]  ; Click coordinates if needed
    Keys := ""            ; Keys to send if MacroType is Keys

    ; Helper method to set coordinates
    SetCoordinates(x, y) {
        this.Coordinates[1] := Integer(x)
        this.Coordinates[2] := Integer(y)
    }
}

; Initialize profiles module
InitializeProfiles() {
    global Profiles := Map()
    LoadAllProfiles()
}

; Load all profiles from the profiles directory
LoadAllProfiles() {
    global Profiles
    Loop Files, ProfilesDir . "\*.ini" {
        profile := LoadProfile(A_LoopFileName)
        if profile
            Profiles[profile.Name] := profile
    }
}

; Load a single profile
LoadProfile(filename) {
    fullPath := ProfilesDir . "\" . filename
    if !FileExist(fullPath)
        return false

    profile := MacroProfile()
    data := ReadIniSection(fullPath, "Profile")
    if !data.Has("Name")
        return false

    ; Load profile data
    profile.Name := data["Name"]
    profile.WindowTitle := data.Get("WindowTitle", "")
    profile.WindowClass := data.Get("WindowClass", "")
    profile.MacroType := data.Get("MacroType", "Click")
    profile.Interval := Integer(data.Get("Interval", 1000))
    profile.Hotkey := data.Get("Hotkey", "")
    
    ; Handle coordinates with proper type conversion
    try {
        coords := StrSplit(data.Get("Coordinates", "0,0"), ",")
        if coords.Length >= 2 {
            x := Integer(Trim(coords[1]))  ; Trim any whitespace
            y := Integer(Trim(coords[2]))  ; Trim any whitespace
            profile.SetCoordinates(x, y)
        }
    } catch as err {
        ShowError("Failed to parse coordinates for profile " . profile.Name . ": " . err.Message)
        profile.SetCoordinates(0, 0)
    }
    
    profile.Keys := data.Get("Keys", "")
    return profile
}

; Save a profile
SaveProfile(profile) {
    if !profile.Name
        return false

    filename := ProfilesDir . "\" . profile.Name . ".ini"
    
    ; Ensure coordinates are numbers
    x := Integer(profile.Coordinates[1])
    y := Integer(profile.Coordinates[2])
    
    data := Map(
        "Name", profile.Name,
        "WindowTitle", profile.WindowTitle,
        "WindowClass", profile.WindowClass,
        "MacroType", profile.MacroType,
        "Interval", profile.Interval,
        "Hotkey", profile.Hotkey,
        "Coordinates", x . "," . y,  ; Store as numbers
        "Keys", profile.Keys
    )

    return WriteIniSection(filename, "Profile", data)
}

; Switch to a different profile
SwitchProfile(profileName) {
    global ActiveProfile, Profiles
    
    if !Profiles.Has(profileName) {
        ShowError("Profile not found: " . profileName)
        return false
    }

    ; Stop current profile if active
    if ActiveProfile && Profiles[ActiveProfile].Enabled
        StopMacro(ActiveProfile)

    ActiveProfile := profileName
    return true
}

; Delete a profile
DeleteProfile(profileName) {
    global Profiles
    
    if !Profiles.Has(profileName)
        return false

    filename := ProfilesDir . "\" . profileName . ".ini"
    try {
        FileDelete(filename)
        Profiles.Delete(profileName)
        return true
    } catch {
        return false
    }
} 