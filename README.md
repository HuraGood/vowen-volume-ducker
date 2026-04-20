# Vowen Volume Ducker

Auto-drop your Windows system volume while you dictate with **[Vowen](https://vowen.ai)**, then restore it when you stop. No more pausing Spotify every time you think of something to say.

- Press **Ctrl+Shift** to start dictating → volume drops to 10%, Vowen starts listening
- Press **Ctrl+Shift** again to stop → volume restores to whatever it was before, Vowen stops
- Normal shortcuts like `Ctrl+Shift+V`, `Ctrl+Shift+T` keep working — no false toggles

## How it works

A tiny AutoHotkey v2 script sits in your system tray as a silent observer. It watches for a clean Ctrl+Shift tap (no other keys pressed in between) and toggles system volume accordingly. It doesn't intercept any keys, so Vowen keeps receiving your input exactly as you typed it.

## Requirements

- Windows 10 or 11
- An AI dictation tool that toggles on **Ctrl+Shift** (Vowen by default — anything else using the same shortcut will work too)

Everything else (AutoHotkey v2) is installed automatically by the installer.

## Install

1. **Clone or download** this repo
2. Open **PowerShell** in the repo folder
3. Run:

   ```powershell
   PowerShell -ExecutionPolicy Bypass -File .\install.ps1
   ```

The installer will:

- Install AutoHotkey v2 via `winget` if you don't already have it
- Copy the script to `%LOCALAPPDATA%\VowenDucker\`
- Create a Startup shortcut so it launches on every login
- Start it immediately

You'll see a green **H** icon in your system tray. That's it.

## Configuration

One knob: how low to drop the volume during dictation. Edit `%LOCALAPPDATA%\VowenDucker\vowen-duck.ahk` and change:

```ahk
DUCK_LEVEL := 10
```

Any number 0–100. Restart the script (right-click tray icon → **Exit**, then double-click the .ahk file) for the change to take effect.

## Uninstall

From the repo folder:

```powershell
PowerShell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

This stops the script, removes the Startup shortcut, and deletes the install directory. AutoHotkey itself is left alone — remove it separately with `winget uninstall AutoHotkey.AutoHotkey` if you want.

## Disable temporarily

Right-click the green **H** tray icon → **Exit**. It comes back on your next login.

## Safety

- The script is plain text — open `vowen-duck.ahk` in any editor and read every line
- No network access, no file I/O beyond itself
- Runs in your user session, no admin rights needed
- AutoHotkey v2 is installed from the official Microsoft-vetted `winget` package, which pulls the signed release from [autohotkey.com](https://autohotkey.com)

## How the Ctrl+Shift guard works

Ctrl+Shift alone is an unusual hotkey because those are normally modifier keys. The script uses AutoHotkey's `InputHook` in **Visible** (non-intercepting) mode — it observes every key event but does not swallow keys. A small state machine tracks whether any non-modifier key was pressed during the Ctrl+Shift hold, and only fires the volume toggle when the combo releases cleanly:

| Keypress | Behaviour |
|----------|-----------|
| Ctrl+Shift (nothing else) | Toggles duck / restore |
| Ctrl+Shift+V (paste) | Does nothing |
| Ctrl+Shift+T (reopen tab) | Does nothing |
| Any other Ctrl+Shift+X combo | Does nothing |

Release order doesn't matter — Ctrl-first or Shift-first both work.

## Use with a different app / shortcut

The script is wired specifically to Ctrl+Shift because that's Vowen's default. If your dictation tool uses a different modifier combo, edit the two helper functions in `vowen-duck.ahk`:

```ahk
IsCtrl(vk)  { return (vk = 0x11 || vk = 0xA2 || vk = 0xA3) }
IsShift(vk) { return (vk = 0x10 || vk = 0xA0 || vk = 0xA1) }
```

Any two modifier keys will work — swap the virtual-key codes (AutoHotkey's [KeyList docs](https://www.autohotkey.com/docs/v2/KeyList.htm) has the full table).

## Troubleshooting

**Volume goes in the wrong direction** — this happens once if your system volume was already at exactly the `DUCK_LEVEL` (10%) when the script started. The internal "is-ducked" state flag flips without an audible change. One normal Ctrl+Shift cycle re-syncs it.

**Nothing happens when I press Ctrl+Shift** — check the tray for a green **H**. No icon means the script isn't running; double-click `%LOCALAPPDATA%\VowenDucker\vowen-duck.ahk` to start it.

**My other app uses Ctrl+Shift differently** — this script only fires on Ctrl+Shift with nothing else pressed, so it shouldn't conflict with `Ctrl+Shift+letter` shortcuts. If you hit an edge case, open an issue.

## License

MIT — see [LICENSE](LICENSE). Use it, change it, ship it.
