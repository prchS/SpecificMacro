# SpecificMacro – Background Automation Tool


**SpecificMacro** is a lightweight desktop automation utility built with **AutoHotkey v2**. It allows you to run macros in the background targeting specific windows without bringing them into focus. This makes it ideal for automating repetitive actions in games, productivity tools, or other applications while continuing your normal workflow.

---

## Features
- **Background Execution** – Send clicks or keystrokes without switching windows.
- **Profile System** – Save configurations for different tasks or applications.
- **Custom Hotkeys** – Start/stop macros instantly.
- **Broad Compatibility** – Works with browsers, desktop apps, Unity-based games, and some DirectX applications.
---

## Quick Start

### For End Users
1. Download the latest `SpecificMacro.exe` from the [Releases](https://github.com/prchs/SpecificMacro/releases) page.
2. Double-click to run.
3. Create a profile in the GUI:
   - Enter the window title and class.
   - Set coordinates, click interval, and hotkey.
4. Press your hotkey to start/stop the macro.

---

## For Developers

### Requirements
- **AutoHotkey v2** installed from [autohotkey.com](https://www.autohotkey.com/)
- **Ahk2Exe** (included with AutoHotkey) for compiling to `.exe`

### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/SpecificMacro.git
   ```
2. Open `main.ahk` with AutoHotkey v2 to run in script form.
3. To compile:
   - Open `Ahk2Exe`.
   - Select `main.ahk`.
   - Include all `.ahk` files.
   - Build into an executable.

---

## Contributing
1. Fork the repository.
2. Create a new feature branch.
3. Implement and test your changes.
4. Submit a pull request with a clear description.

---

## File Structure
```
SpecificMacro/
├── main.ahk             # Entry point
├── macro_engine.ahk     # Core automation logic
├── profile.ahk          # Profile management
├── gui.ahk              # User interface
├── hotkeys.ahk          # Hotkey handling
├── utils.ahk            # Utility functions
├── create_profile.ahk   # Profile creation tool
├── profiles/            # Saved profiles
└── Releases/            # Compiled executables
    └── SpecificMacro.exe
```

---

## Technical Details
- **Supported Windows:** Standard apps, Unity games, some DirectX titles, system windows.
- **Input Methods:**
  - `PostMessage` for background input.
  - `SendInput` for low-level simulation in games.
  - `ControlSend` for background keyboard input.
- **Performance:**
  - Memory usage: ~10–20 MB.
  - CPU usage: Minimal when idle, low during execution.

---

## License
Open source — free to use, modify, and distribute.

---

## Disclaimer
This software is for lawful automation purposes only. Users must ensure compliance with any relevant terms of service. The developers are not liable for misuse.
