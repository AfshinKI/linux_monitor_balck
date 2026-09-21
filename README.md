# monitor-black

Turn the display off *immediately* on Linux, and ignore the keyboard and mouse
for the next 10 seconds so a stray keypress or a nudged mouse does not light it
straight back up.

Handy when you walk away from the desk, or when you want the panel dark while
something is still running.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/AfshinKI/linux_monitor_balck/main/install.sh | bash
```

That installs `~/.local/bin/monitor-black`, adds a **Monitor Black** launcher,
and pins it to the GNOME dash.

## Use

Click **Monitor Black** in the dash, or from a terminal:

```bash
monitor-black        # off now, input ignored for 10 s
monitor-black 30     # same, 30 s lockout
monitor-black 0      # off now, no lockout
```

After the lockout expires, any key or mouse move wakes the display as usual.

### Bind it to a key (GNOME)

Settings → Keyboard → Keyboard Shortcuts → Custom Shortcuts → `+`, command
`monitor-black`, and pick a shortcut such as <kbd>Super</kbd>+<kbd>B</kbd>.

## How it works

- Forces DPMS off through `DPMSForceLevel` (falling back to `xset dpms force off`).
- Takes an exclusive X keyboard and pointer grab, so input reaches nothing and is
  discarded rather than replayed when the grab ends.
- Re-asserts the off state every 0.4 s for the whole lockout, because input
  resets the X server's DPMS timer even while grabbed.

## Requirements

X11 session (Ubuntu's default GNOME on Xorg), Python 3, `libX11`/`libXext` — all
present on a stock Ubuntu desktop. No extra packages, no root.

On Wayland an unprivileged process cannot grab all input, so the tool refuses to
run; log in with "Ubuntu on Xorg" from the gear on the login screen.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/AfshinKI/linux_monitor_balck/main/uninstall.sh | bash
```
