#!/usr/bin/env bash
# Install monitor-black: binary, desktop entry, dash pin, and Ctrl+F12 shortcut.
# One-liner:
#   curl -fsSL https://raw.githubusercontent.com/AfshinKI/linux_monitor_balck/main/install.sh | bash
set -euo pipefail

RAW="${MONITOR_BLACK_RAW:-https://raw.githubusercontent.com/AfshinKI/linux_monitor_balck/main}"
BIN_DIR="${HOME}/.local/bin"
APP_DIR="${HOME}/.local/share/applications"
DESKTOP_ID="monitor-black.desktop"

mkdir -p "$BIN_DIR" "$APP_DIR"

# When run from a clone, install those files; when piped from curl, download.
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"

fetch() { # fetch <name> <destination>
  local src="$1" dst="$2"
  if [ -n "$SRC_DIR" ] && [ -f "$SRC_DIR/$src" ]; then
    cp "$SRC_DIR/$src" "$dst"
  else
    curl -fsSL "$RAW/$src" -o "$dst"
  fi
}

fetch monitor-black "$BIN_DIR/monitor-black"
chmod +x "$BIN_DIR/monitor-black"
fetch "$DESKTOP_ID" "$APP_DIR/$DESKTOP_ID"

# The launcher calls the binary by name, so ~/.local/bin has to be on PATH for
# the GNOME session too; an absolute Exec= keeps it working either way.
sed -i "s|^Exec=monitor-black|Exec=${BIN_DIR}/monitor-black|" "$APP_DIR/$DESKTOP_ID"

command -v update-desktop-database >/dev/null 2>&1 && \
  update-desktop-database "$APP_DIR" 2>/dev/null || true

# Pin to the dash (GNOME favourites), keeping whatever is already there.
if command -v gsettings >/dev/null 2>&1; then
  python3 - "$DESKTOP_ID" <<'PY' || echo "Could not pin to the dash - add it from the app grid instead."
import subprocess, sys
key = ("org.gnome.shell", "favorite-apps")
desktop_id = sys.argv[1]
current = subprocess.run(["gsettings", "get", *key], capture_output=True,
                         text=True, check=True).stdout.strip()
favs = [f.strip().strip("'\"") for f in current.strip("[]").split(",") if f.strip()]
if desktop_id not in favs:
    favs.append(desktop_id)
    subprocess.run(["gsettings", "set", *key,
                    "[" + ", ".join("'%s'" % f for f in favs) + "]"], check=True)
    print("Pinned 'Monitor Black' to the dash.")
else:
    print("Already pinned to the dash.")
PY
fi

# Register Ctrl+F12 as a GNOME custom shortcut.  The fixed path makes repeated
# installations update this shortcut instead of adding duplicates.
if command -v gsettings >/dev/null 2>&1; then
  python3 - "$BIN_DIR/monitor-black" <<'PY' || echo "Could not set Ctrl+F12 - add it from Settings → Keyboard instead."
import subprocess, sys

command = sys.argv[1]
key = ("org.gnome.settings-daemon.plugins.media-keys", "custom-keybindings")
path = "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/monitor-black/"
current = subprocess.run(["gsettings", "get", *key], capture_output=True,
                         text=True, check=True).stdout.strip()
paths = [p.strip().strip("'\"") for p in current.strip("[]").split(",") if p.strip()]
if path not in paths:
    paths.append(path)
    subprocess.run(["gsettings", "set", *key,
                    "[" + ", ".join("'%s'" % p for p in paths) + "]"], check=True)

schema = "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"
base = schema + path
subprocess.run(["gsettings", "set", base, "name", "Monitor Black"], check=True)
subprocess.run(["gsettings", "set", base, "command", command], check=True)
subprocess.run(["gsettings", "set", base, "binding", "<Control>F12"], check=True)
print("Set Ctrl+F12 to Monitor Black.")
PY
fi

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo "Note: $BIN_DIR is not on your PATH; run it as $BIN_DIR/monitor-black" ;;
esac

echo "Installed. Click 'Monitor Black' in the dash, or run: monitor-black [seconds]"
