# SpecificMacro - Background Automation Tool

A powerful desktop automation tool built with AutoHotkey v2 that allows you to create macros that run in the background, targeting specific windows without requiring focus. Perfect for automating repetitive tasks in games, applications, or any window-based software.

## Features

- **Background Operation**: Macros run without stealing focus from your active window
- **Multi-Profile Support**: Create and manage multiple automation profiles
- **Window Targeting**: Target specific windows by title and class
- **Flexible Input Types**: Support for mouse clicks and keyboard input
- **Game Compatibility**: Special handling for game windows (Roblox, Unity, etc.)
- **Easy Profile Management**: GUI for creating, editing, and managing profiles
- **Hotkey Control**: Start/stop macros with customizable hotkeys
- **Real-time Feedback**: Non-blocking tooltips show macro status

## Quick Start

### For End Users

1. **Download**: Go to the [Releases](https://github.com/yourusername/SpecificMacro/releases) section
2. **Download**: Download the latest `SpecificMacro.exe` file
3. **Run**: Double-click the executable to start the application
4. **Create Profile**: Use the GUI to create your first automation profile
5. **Start Macro**: Press your configured hotkey to start/stop the macro

### For Developers

1. **Clone**: `git clone https://github.com/yourusername/SpecificMacro.git`
2. **Install**: Install AutoHotkey v2 from [autohotkey.com](https://www.autohotkey.com/)
3. **Run**: Execute `main.ahk` to start the application

## How It Works

### Profile System
Each profile defines:
- **Target Window**: Window title and class to automate
- **Click Coordinates**: X,Y coordinates relative to the window
- **Click Interval**: Time between clicks (in milliseconds)
- **Hotkey**: Key combination to start/stop the macro
- **Input Type**: Mouse clicks or keyboard input

### Background Operation
The tool uses advanced Windows API calls to:
- Send clicks without activating the target window
- Preserve your current mouse position
- Work with both regular applications and games
- Maintain focus on your active window

## Usage Examples

### Chrome Automation
```ini
[Profile]
Name=ChromeClicker
WindowTitle=Google Chrome
WindowClass=ahk_class Chrome_WidgetWin_1
MacroType=Click
Interval=1000
Hotkey=\
Coordinates=150,150
```

### Roblox Game Automation
```ini
[Profile]
Name=RobloxClicker
WindowTitle=Roblox
WindowClass=ahk_class WINDOWSCLIENT
MacroType=Click
Interval=500
Hotkey=F1
Coordinates=200,200
```

## File Structure

```
SpecificMacro/
├── main.ahk              # Main application entry point
├── macro_engine.ahk      # Core automation logic
├── profile.ahk           # Profile management system
├── gui.ahk              # User interface
├── hotkeys.ahk          # Hotkey handling
├── utils.ahk            # Utility functions
├── create_profile.ahk   # Profile creation tool
├── profiles/            # Profile storage directory
│   ├── ChromeClicker.ini
│   └── RobloxClicker.ini
└── Releases/           # Compiled executables
    └── SpecificMacro.exe
```

## Creating Profiles

### Using the GUI
1. Run the application
2. Click "New Profile" in the GUI
3. Fill in the profile details:
   - **Profile Name**: Unique identifier for your profile
   - **Window Title**: Title of the target window
   - **Window Class**: Class of the target window
   - **Coordinates**: X,Y coordinates for clicks
   - **Interval**: Time between clicks (ms)
   - **Hotkey**: Key to start/stop the macro

### Using the Profile Creator
1. Run `create_profile.ahk`
2. Use the "Get Active Window" button to auto-fill window details
3. Adjust settings as needed
4. Click "Create Profile"

### Manual Profile Creation
Create `.ini` files in the `profiles/` directory with this structure:
```ini
[Profile]
Name=YourProfileName
WindowTitle=Target Window Title
WindowClass=ahk_class WindowClassName
MacroType=Click
Interval=1000
Hotkey=\
Coordinates=150,150
Keys=
```

## Finding Window Information

### Using the Profile Creator
1. Open the target application
2. Run `create_profile.ahk`
3. Click "Get Active Window" while the target window is active
4. The window title and class will be automatically filled

### Manual Method
1. Use Windows Spy (included with AutoHotkey) to find window details
2. Or use the built-in window picker in the GUI

## Troubleshooting

### Macro Not Working
1. **Check Window Targeting**: Ensure the window title and class are correct
2. **Verify Coordinates**: Make sure coordinates are within the window bounds
3. **Run as Administrator**: Some applications require elevated privileges
4. **Check Anti-Cheat**: Some games block automated input

### Clicks Not Registering in Games
1. **Use Game Mode**: The tool automatically detects game windows
2. **Run as Administrator**: Required for many games
3. **Check Game Settings**: Some games have input restrictions
4. **Try Different Coordinates**: Game UI elements may have different click areas

### Hotkey Not Working
1. **Check Conflicts**: Ensure the hotkey isn't used by another application
2. **Restart Application**: Sometimes hotkeys need a restart to register
3. **Check Profile**: Verify the hotkey is set in your profile

## Technical Details

### Supported Window Types
- **Regular Windows**: Browsers, applications, etc.
- **Game Windows**: Roblox, Unity games, DirectX applications
- **System Windows**: Windows Explorer, Control Panel, etc.

### Input Methods
- **PostMessage**: For regular windows (background operation)
- **SendInput**: For game windows (low-level input simulation)
- **ControlSend**: For keyboard input (background operation)

### Performance
- **Memory Usage**: ~10-20MB typical
- **CPU Usage**: Minimal (only during macro execution)
- **Response Time**: <1ms for hotkey detection

## Building from Source

### Requirements
- AutoHotkey v2.0 or later
- Windows 10/11 (may work on Windows 8.1)

### Compilation
1. Install Ahk2Exe (included with AutoHotkey)
2. Compile `main.ahk` to create the executable
3. Include all `.ahk` files in the compilation

### Development
- All modules are included via `#Include` directives
- Profiles are stored as INI files for easy editing
- GUI is built using AutoHotkey's native GUI system

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is open source. Feel free to modify and distribute according to your needs.

## Support

For issues, questions, or feature requests:
1. Check the troubleshooting section above
2. Search existing issues
3. Create a new issue with detailed information

## Disclaimer

This tool is for legitimate automation purposes only. Users are responsible for complying with the terms of service of any applications they automate. The developers are not responsible for any misuse of this software.

---

**Note**: Always run the latest version from the [Releases](https://github.com/yourusername/SpecificMacro/releases) section for the best experience and latest features. 