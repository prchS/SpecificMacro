#Requires AutoHotkey v2.0

; Initialize GUI module
InitializeGUI() {
    global MainGui := {}
    CreateMainWindow()
}

; Create the main application window
CreateMainWindow() {
    global MainGui
    
    ; Create the main window
    MainGui.Window := Gui("+Resize", AppName)
    MainGui.Window.OnEvent("Close", (*) => ExitApp())
    MainGui.Window.SetFont("s10", "Segoe UI")

    ; Add menu bar
    MainGui.MenuBar := MenuBar()
    fileMenu := Menu()
    fileMenu.Add("New Profile", (*) => ShowNewProfileDialog())
    fileMenu.Add("Exit", (*) => ExitApp())
    MainGui.MenuBar.Add("&File", fileMenu)
    MainGui.Window.MenuBar := MainGui.MenuBar

    ; Create tabs
    MainGui.Tabs := MainGui.Window.Add("Tab3", "w600 h400", ["Profiles", "Settings"])

    ; Profiles tab
    MainGui.Tabs.UseTab(1)
    
    ; Profile list
    MainGui.ProfileList := MainGui.Window.Add("ListView", "w580 h200", ["Name", "Window", "Type", "Interval", "Hotkey", "Status"])
    MainGui.ProfileList.OnEvent("DoubleClick", ProfileListDoubleClick)
    
    ; Buttons
    buttonsGroup := MainGui.Window.Add("GroupBox", "w580 h60", "Actions")
    MainGui.Window.Add("Button", "xp+10 yp+20 w100", "New").OnEvent("Click", (*) => ShowNewProfileDialog())
    MainGui.Window.Add("Button", "x+10 w100", "Edit").OnEvent("Click", (*) => EditSelectedProfile())
    MainGui.Window.Add("Button", "x+10 w100", "Delete").OnEvent("Click", (*) => DeleteSelectedProfile())
    MainGui.Window.Add("Button", "x+10 w100", "Start/Stop").OnEvent("Click", (*) => ToggleSelectedProfile())

    ; Settings tab
    MainGui.Tabs.UseTab(2)
    MainGui.Window.Add("Text",, "Global Settings")
    ; Add global settings controls here

    ; Switch back to first tab
    MainGui.Tabs.UseTab()
    
    ; Update profile list
    UpdateProfileList()
}

; Show the main window
ShowMainGUI() {
    global MainGui
    MainGui.Window.Show()
}

; Update the profile list view
UpdateProfileList() {
    global MainGui, Profiles
    
    MainGui.ProfileList.Delete()
    
    for profileName, profile in Profiles {
        status := profile.Enabled ? "Running" : "Stopped"
        MainGui.ProfileList.Add(,
            profile.Name,
            profile.WindowTitle,
            profile.MacroType,
            FormatDuration(profile.Interval),
            profile.Hotkey,
            status
        )
    }
    
    MainGui.ProfileList.ModifyCol()  ; Auto-size columns
}

; Show window picker dialog
ShowWindowPicker(winTitleControl, winClassControl) {
    global WindowPickerGui := Gui("+Owner" . MainGui.Window.Hwnd, "Window Picker")
    WindowPickerGui.SetFont("s10", "Segoe UI")
    
    ; Add ListView for windows
    WindowPickerGui.Add("Text",, "Double-click a window to select it:")
    listView := WindowPickerGui.Add("ListView", "w400 h300", ["Window Title", "Process", "Class"])
    
    ; Populate window list
    windows := GetOpenWindows()
    for window in windows {
        listView.Add(, window["title"], window["process"], window["class"])
    }
    
    ; Auto-size columns
    listView.ModifyCol()
    
    ; Handle double-click
    listView.OnEvent("DoubleClick", HandleWindowPickerDoubleClick.Bind(listView, winTitleControl, winClassControl, WindowPickerGui))
    
    ; Add close button
    WindowPickerGui.Add("Button", "w80", "Close").OnEvent("Click", (*) => WindowPickerGui.Destroy())
    
    WindowPickerGui.Show()
}

; Handle window picker double-click
HandleWindowPickerDoubleClick(listView, winTitleControl, winClassControl, WindowPickerGui, *) {
    row := listView.GetNext()
    if row {
        winTitleControl.Value := listView.GetText(row, 1)
        winClassControl.Value := listView.GetText(row, 3)
        WindowPickerGui.Destroy()
    }
}

; Show new profile dialog
ShowNewProfileDialog() {
    global NewProfileGui := Gui("+Owner" . MainGui.Window.Hwnd, "New Profile")
    NewProfileGui.SetFont("s10", "Segoe UI")
    
    ; Add controls
    NewProfileGui.Add("Text",, "Profile Name:")
    name := NewProfileGui.Add("Edit", "w200")
    
    NewProfileGui.Add("Text", "xm", "Window Title:")
    winTitle := NewProfileGui.Add("Edit", "w200")
    
    NewProfileGui.Add("Text", "xm", "Window Class:")
    winClass := NewProfileGui.Add("Edit", "w200")
    
    ; Add window picker button
    NewProfileGui.Add("Button", "x+5 yp-1 w80", "Pick Window").OnEvent("Click", (*) => ShowWindowPicker(winTitle, winClass))
    
    NewProfileGui.Add("Text", "xm", "Macro Type:")
    macroType := NewProfileGui.Add("DropDownList", "w200", ["Click", "Keys"])
    
    NewProfileGui.Add("Text", "xm", "Interval (ms):")
    interval := NewProfileGui.Add("Edit", "w200", "1000")
    
    NewProfileGui.Add("Text", "xm", "Hotkey:")
    hotkey := NewProfileGui.Add("Hotkey", "w200")
    
    ; Add buttons
    NewProfileGui.Add("Button", "xm w90", "OK").OnEvent("Click", (*) => SaveNewProfile(
        name.Value, winTitle.Value, winClass.Value, macroType.Value,
        Integer(interval.Value), hotkey.Value
    ))
    NewProfileGui.Add("Button", "x+10 w90", "Cancel").OnEvent("Click", (*) => NewProfileGui.Destroy())
    
    NewProfileGui.Show()
}

; Save new profile
SaveNewProfile(name, winTitle, winClass, macroType, interval, hotkeyStr) {
    global NewProfileGui, Profiles
    
    if !name {
        ShowError("Profile name is required!")
        return
    }

    if Profiles.Has(name) {
        ShowError("Profile name already exists!")
        return
    }

    ; Create new profile
    try {
        profile := MacroProfile()
        profile.Name := name
        profile.WindowTitle := winTitle
        profile.WindowClass := winClass
        profile.MacroType := macroType
        profile.Interval := interval
        profile.Hotkey := hotkeyStr

        ; Save profile
        if SaveProfile(profile) {
            Profiles[name] := profile
            if profile.Hotkey
                RegisterProfileHotkey(profile)
            UpdateProfileList()
            NewProfileGui.Destroy()
        }
    } catch as err {
        ShowError("Failed to create profile: " . err.Message)
    }
}

; Edit selected profile
EditSelectedProfile() {
    global MainGui
    
    if !MainGui.ProfileList.GetNext() {
        ShowError("Please select a profile to edit!")
        return
    }

    profileName := MainGui.ProfileList.GetText(MainGui.ProfileList.GetNext(), 1)
    ShowEditProfileDialog(profileName)
}

; Show edit profile dialog
ShowEditProfileDialog(profileName) {
    global EditProfileGui := Gui("+Owner" . MainGui.Window.Hwnd, "Edit Profile")
    global Profiles, Profile
    EditProfileGui.SetFont("s10", "Segoe UI")
    
    profile := Profiles[profileName]
    
    ; Add controls (similar to new profile dialog but with existing values)
    EditProfileGui.Add("Text",, "Profile Name:")
    name := EditProfileGui.Add("Edit", "w200 ReadOnly", profile.Name)
    
    EditProfileGui.Add("Text", "xm", "Window Title:")
    winTitle := EditProfileGui.Add("Edit", "w200", profile.WindowTitle)
    
    EditProfileGui.Add("Text", "xm", "Window Class:")
    winClass := EditProfileGui.Add("Edit", "w200", profile.WindowClass)
    
    ; Add window picker button
    EditProfileGui.Add("Button", "x+5 yp-1 w80", "Pick Window").OnEvent("Click", (*) => ShowWindowPicker(winTitle, winClass))
    
    EditProfileGui.Add("Text", "xm", "Macro Type:")
    macroType := EditProfileGui.Add("DropDownList", "w200", ["Click", "Keys"])
    macroType.Value := profile.MacroType = "Click" ? 1 : 2
    
    EditProfileGui.Add("Text", "xm", "Interval (ms):")
    interval := EditProfileGui.Add("Edit", "w200", profile.Interval)
    
    EditProfileGui.Add("Text", "xm", "Hotkey:")
    hotkey := EditProfileGui.Add("Hotkey", "w200", profile.Hotkey)
    
    ; Add buttons
    EditProfileGui.Add("Button", "xm w90", "Save").OnEvent("Click", (*) => SaveEditedProfile(
        profile.Name, winTitle.Value, winClass.Value, macroType.Value,
        Integer(interval.Value), hotkey.Value
    ))
    EditProfileGui.Add("Button", "x+10 w90", "Cancel").OnEvent("Click", (*) => EditProfileGui.Destroy())
    
    EditProfileGui.Show()
}

; Save edited profile
SaveEditedProfile(name, winTitle, winClass, macroType, interval, hotkeyStr) {
    global EditProfileGui, Profiles
    
    profile := Profiles[name]
    
    ; Update profile
    profile.WindowTitle := winTitle
    profile.WindowClass := winClass
    profile.MacroType := macroType
    profile.Interval := interval
    
    ; Update hotkey if changed
    if (profile.Hotkey != hotkeyStr)
        UpdateProfileHotkey(name, hotkeyStr)
    
    ; Save profile
    if SaveProfile(profile) {
        UpdateProfileList()
        EditProfileGui.Destroy()
    }
}

; Delete selected profile
DeleteSelectedProfile() {
    global MainGui
    
    if !MainGui.ProfileList.GetNext() {
        ShowError("Please select a profile to delete!")
        return
    }

    profileName := MainGui.ProfileList.GetText(MainGui.ProfileList.GetNext(), 1)
    
    if (MsgBox("Are you sure you want to delete profile '" . profileName . "'?",
        AppName, "YesNo Icon?") = "Yes") {
        if DeleteProfile(profileName) {
            UnregisterProfileHotkey(profileName)
            UpdateProfileList()
        }
    }
}

; Toggle selected profile
ToggleSelectedProfile() {
    global MainGui
    
    if !MainGui.ProfileList.GetNext() {
        ShowError("Please select a profile!")
        return
    }

    profileName := MainGui.ProfileList.GetText(MainGui.ProfileList.GetNext(), 1)
    ToggleMacro(profileName)
    UpdateProfileList()
}

; Handle double-click on profile list
ProfileListDoubleClick(*) {
    global MainGui
    
    if !MainGui.ProfileList.GetNext()
        return

    profileName := MainGui.ProfileList.GetText(MainGui.ProfileList.GetNext(), 1)
    ShowEditProfileDialog(profileName)
} 