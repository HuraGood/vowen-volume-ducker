# Vowen Volume Ducker

**Auto-duck (lower) your Windows system volume the moment you start dictating, then restore it when you stop.** Built for [Vowen](https://vowen.ai) but works with **any Windows dictation, voice-to-text, speech-to-text, or push-to-talk app** that toggles on `Ctrl+Shift` — including Wispr Flow, Willow Voice, Superwhisper on Windows, or any app where you can reassign the shortcut.

No more manually pausing Spotify, YouTube Music, Apple Music, a podcast, or a video every time you talk to your AI voice assistant. Press `Ctrl+Shift`, your music drops to 10% and your dictation app starts. Press `Ctrl+Shift` again, your music comes straight back.

> **Not affiliated with Vowen.** This is an independent open-source Windows utility. The Vowen name is used here under nominative fair use to identify the dictation tool this project is designed to complement.

## Why this exists

If you dictate a lot with an AI voice tool on Windows while music or a podcast is playing, you've probably noticed:

- The music drowns out your thoughts mid-sentence
- You forget to pause Spotify and end up talking over it
- The dictation app records the music along with your voice, degrading transcription quality
- Windows has no built-in "duck audio when I'm talking" feature for third-party apps

Mac users have had [WisprDuck](https://github.com/kalepail/wispr-duck) for exactly this. Windows didn't have a good equivalent. This fills that gap.

## Features

- **Automatic volume ducking** — system volume drops to 10% the instant you start dictating
- **Exact restore** — remembers the precise level you were at (e.g. 47%) and snaps back to it
- **Zero lag and zero interference** with your dictation tool — uses a non-intercepting keyboard observer, so Vowen (or whatever you use) receives every keystroke untouched
- **Normal shortcuts still work** — `Ctrl+Shift+V` (paste), `Ctrl+Shift+T` (reopen tab), `Ctrl+Shift+S` (save as) all pass through unaffected
- **Auto-starts on every login** — install once, forget it exists
- **Adjustable duck level** — set anywhere from silent (0%) to no change (100%)
- **~90 lines of plain-text AutoHotkey v2** — readable and auditable
- **No admin rights, no network calls, no telemetry, no third-party dependencies** beyond AutoHotkey itself

## Compatible apps

Works with any Windows app — dictation, voice control, or push-to-talk — that toggles on `Ctrl+Shift`:

| App | Out of the box? |
|-----|-----------------|
| **[Vowen](https://vowen.ai)** | Yes — uses `Ctrl+Shift` by default |
| **Wispr Flow (Windows)** | Yes — if you set its shortcut to `Ctrl+Shift` |
| **Willow Voice** | Yes — if you set its shortcut to `Ctrl+Shift` |
| **Superwhisper (Windows)** | Yes — if you set its shortcut to `Ctrl+Shift` |
| **Talon Voice, Dragon NaturallySpeaking, others** | Yes — if the toggle is `Ctrl+Shift` |
| **Discord / TeamSpeak / Mumble push-to-talk** | Yes — if PTT is bound to `Ctrl+Shift` |
| **Any other shortcut** | Yes, with a one-line edit — see [Use with a different shortcut](#use-with-a-different-shortcut) |

## Requirements

- **Windows 10 or 11**
- **A dictation or push-to-talk app installed separately** — this project only ducks the system volume, it does not transcribe speech. Install [Vowen](https://vowen.ai) (or your chosen equivalent) from its official site
- **AutoHotkey v2** — installed automatically by the included installer

## Install

1. Clone or download this repo
2. Open **PowerShell** in the repo folder
3. Run:

   ```powershell
   PowerShell -ExecutionPolicy Bypass -File .\install.ps1
   ```

The installer handles everything:

- Installs AutoHotkey v2 via `winget` if you don't already have it (from the official Microsoft-vetted package)
- Copies the script to `%LOCALAPPDATA%\VowenDucker\`
- Creates a Startup shortcut so it launches on every login
- Starts it immediately

You'll see a green **H** icon in your system tray. That's it.

## Configuration

The only knob is **how low to drop the volume** during dictation. Edit `%LOCALAPPDATA%\VowenDucker\vowen-duck.ahk` and change:

```ahk
DUCK_LEVEL := 10
```

Any value from `0` (silent) to `100` (no change). Common choices: `5` for near-silence, `10` for the default low-but-audible floor, `25` for subtle ducking. Restart the script (right-click the tray icon → **Exit**, then double-click the `.ahk` file) for the change to take effect.

## Uninstall

From the repo folder:

```powershell
PowerShell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

This stops the script, removes the Startup shortcut, and deletes the install directory. AutoHotkey itself is left installed — remove it separately with `winget uninstall AutoHotkey.AutoHotkey` if you want.

## Disable temporarily

Right-click the green **H** tray icon → **Exit**. It comes back on your next login.

## Safety

- The script is plain text — open `vowen-duck.ahk` in any editor and read every line
- **No network access**, no file I/O beyond the script itself, **no telemetry**
- Runs in your user session — **no admin rights required**
- AutoHotkey v2 is installed from the official Microsoft-vetted `winget` package, which pulls the signed release directly from [autohotkey.com](https://autohotkey.com)
- Observer-only: it uses AutoHotkey's `InputHook` in **Visible** (non-intercepting) mode, which means it watches the keyboard without consuming or modifying any keypress

## How the Ctrl+Shift guard works

`Ctrl+Shift` alone is an unusual hotkey because those are normally modifier keys. The script uses AutoHotkey's `InputHook` in **Visible** (non-intercepting) mode — it observes every key event but does not swallow keys. A small state machine tracks whether any non-modifier key was pressed during the `Ctrl+Shift` hold, and only fires the volume toggle when the combo releases cleanly:

| Keypress | Behaviour |
|----------|-----------|
| `Ctrl+Shift` (nothing else) | Toggles duck / restore |
| `Ctrl+Shift+V` (paste) | Does nothing |
| `Ctrl+Shift+T` (reopen tab) | Does nothing |
| `Ctrl+Shift+S`, `Ctrl+Shift+N`, any other combo | Does nothing |

Release order doesn't matter — Ctrl-first or Shift-first both fire correctly.

## Use with a different shortcut

The script is wired to `Ctrl+Shift` because that's Vowen's default. If your dictation or push-to-talk app uses a different modifier combo (e.g. `Alt+Shift`, `Win+Space`, etc.), edit the two helper functions in `vowen-duck.ahk`:

```ahk
IsCtrl(vk)  { return (vk = 0x11 || vk = 0xA2 || vk = 0xA3) }
IsShift(vk) { return (vk = 0x10 || vk = 0xA0 || vk = 0xA1) }
```

Replace the virtual-key codes with whichever keys you want to watch. AutoHotkey's [KeyList docs](https://www.autohotkey.com/docs/v2/KeyList.htm) has the full table.

## Troubleshooting

**Volume doesn't change on the first press if I start at exactly 10%** — if your system volume is already at the `DUCK_LEVEL` when you first press Ctrl+Shift, the script has no meaningfully-louder "previous" volume to remember. It will reassert the duck level (no audible change). Raise the volume manually once to something above 10%, then Ctrl+Shift again, and it'll capture that as your new previous.

**Nothing happens when I press Ctrl+Shift** — check the tray for a green **H**. No icon means the script isn't running; double-click `%LOCALAPPDATA%\VowenDucker\vowen-duck.ahk` to start it. If there's still no effect, your dictation app may be using a different shortcut than `Ctrl+Shift` — check its settings.

**My other app uses Ctrl+Shift differently** — this script only fires on `Ctrl+Shift` with nothing else pressed, so it shouldn't conflict with any `Ctrl+Shift+letter` shortcut. If you hit an edge case, [open an issue](https://github.com/HuraGood/vowen-volume-ducker/issues).

**Vowen doesn't respond after I install this** — shouldn't happen: the script uses `InputHook` in Visible mode precisely so keys pass through untouched. If it does happen, exit the tray icon and report it — logs can be enabled in the script for diagnosis.

## FAQ

**Can I use this without Vowen?**
Yes. The script only watches for the `Ctrl+Shift` keyboard pattern and adjusts system volume. It has no connection to Vowen whatsoever. Any dictation or push-to-talk app that toggles on `Ctrl+Shift` will work identically.

**How do I auto-pause Spotify when I start dictating on Windows?**
This doesn't pause Spotify — it ducks the entire system volume to a quiet level (10% by default), which achieves the same practical effect without having to integrate with Spotify specifically. It works the same way for YouTube Music, Apple Music, podcast apps, background video, Discord calls, anything.

**Does this work with Wispr Flow, Willow Voice, or Superwhisper?**
Yes, as long as you set the app's shortcut to `Ctrl+Shift` in its settings. The script doesn't care which app you're using — it only cares about the keypress pattern.

**Will this interfere with Ctrl+Shift+V, Ctrl+Shift+T, or other shortcuts?**
No. The script specifically requires `Ctrl+Shift` to be pressed and released with nothing else in between. Any `Ctrl+Shift+letter` combo is ignored — the `V`, `T`, `S` etc. "dirty" the combo and the volume toggle won't fire.

**Is it safe?**
Yes. It's a plain-text AutoHotkey v2 script, roughly 90 lines. No network access, no admin privileges, no telemetry, no file I/O beyond its own script file. Open `vowen-duck.ahk` in Notepad and you can read every line of what it does. See the [Safety](#safety) section for more detail.

**Does this work on macOS or Linux?**
No — it's Windows-only (10 and 11). On macOS, use [WisprDuck](https://github.com/kalepail/wispr-duck). On Linux, the [audio_Ducking_For_Music](https://github.com/grahamna/audio_Ducking_For_Music) project provides a similar capability using PulseAudio or PipeWire.

**How is this different from WisprDuck on macOS?**
WisprDuck detects microphone activity and ducks accordingly. This project detects a keyboard toggle (`Ctrl+Shift`) instead, because Windows doesn't expose mic activity the same way macOS does. The hotkey-based approach actually has an advantage: it ducks the instant you press the shortcut, before you've started speaking, which means you never lose the first syllable.

**How is this different from Windows' built-in "Communications" ducking?**
Windows can auto-duck when it detects a "communications" device (e.g. a Skype or Teams call). This only works for apps that register as communications apps with the OS. Vowen and most third-party dictation apps don't. This script fills that gap for any app that uses a hotkey toggle.

**Can I change the duck volume level?**
Yes — edit the `DUCK_LEVEL := 10` line in `vowen-duck.ahk`. Any value 0–100.

**Can I change the shortcut to something other than Ctrl+Shift?**
Yes — see [Use with a different shortcut](#use-with-a-different-shortcut). Any two modifier keys can be used by swapping their virtual-key codes in the script.

**Does it survive a reboot?**
Yes. The installer adds a shortcut to `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\` so it launches automatically on every login.

**Does it work with multiple audio devices / external DACs / Bluetooth headphones?**
Yes. It controls the default Windows playback device, so whichever output is currently active (speakers, headphones, DAC, Bluetooth) is what gets ducked.

**Can I contribute or request a feature?**
Yes, [open an issue or pull request](https://github.com/HuraGood/vowen-volume-ducker/issues) on GitHub.

## Acknowledgements

Inspired by **[WisprDuck](https://github.com/kalepail/wispr-duck)** by [kalepail](https://github.com/kalepail) — a macOS menu bar utility that auto-ducks background audio when the microphone is active. This project is the Windows counterpart, aimed at hotkey-toggled dictation and push-to-talk apps rather than mic-activity detection.

Built on [AutoHotkey v2](https://autohotkey.com), which does the heavy lifting of observing keyboard events and controlling Windows audio.

## License

MIT — see [LICENSE](LICENSE). Use it, fork it, modify it, ship it.

---

### Keywords

Windows volume ducker · auto-duck system volume · voice dictation volume · Vowen Spotify pause · Wispr Flow volume · Willow Voice · Superwhisper Windows · AutoHotkey volume script · push-to-talk volume ducking Windows · auto pause music when dictating · lower volume on hotkey · Ctrl+Shift volume toggle · WisprDuck for Windows · dictation-friendly volume control · voice-to-text Windows background audio · AI voice assistant volume ducker · speech-to-text Spotify auto-pause
