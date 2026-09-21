#!/usr/bin/env bash
# Remove monitor-black and unpin it from the GNOME dash.
set -euo pipefail

BIN="${HOME}/.local/bin/monitor-black"
DESKTOP_ID="monitor-black.desktop"
DESKTOP="${HOME}/.local/share/applications/${DESKTOP_ID}"

if command -v gsettings >/dev/null 2>&1; then
  python3 - "$DESKTOP_ID" <<'PY' || true
import subprocess, sys
key = ("org.gnome.shell", "favorite-apps")
desktop_id = sys.argv[1]
current = subprocess.run(["gsettings", "get", *key], capture_output=True,
                         text=True).stdout.strip()
favs = [f.strip().strip("'\"") for f in current.strip("[]").split(",") if f.strip()]
if desktop_id in favs:
    favs = [f for f in favs if f != desktop_id]
    subprocess.run(["gsettings", "set", *key,
                    "[" + ", ".join("'%s'" % f for f in favs) + "]"], check=True)
    print("Unpinned from the dash.")
PY
fi

rm -f "$BIN" "$DESKTOP"
command -v update-desktop-database >/dev/null 2>&1 && \
  update-desktop-database "${HOME}/.local/share/applications" 2>/dev/null || true
echo "monitor-black removed."
