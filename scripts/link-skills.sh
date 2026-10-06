#!/usr/bin/env bash
# Symlink every skills/*/SKILL.md directory into each agent harness's skill dir,
# so a `git pull` is all it takes to update. Works on Linux, macOS, WSL and
# Git Bash on Windows (needs Developer Mode or admin for native symlinks).
#
# Usage: scripts/link-skills.sh            # link into default harness dirs
#        scripts/link-skills.sh ~/.codex/skills   # link into custom dir(s)
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
if [ $# -gt 0 ]; then DESTS=("$@"); else DESTS=("$HOME/.claude/skills" "$HOME/.agents/skills"); fi

# Git Bash on Windows copies by default; ask for a native symlink/junction instead.
case "$(uname -s)" in MINGW*|MSYS*) export MSYS=winsymlinks:native ;; esac

for DEST in "${DESTS[@]}"; do
  mkdir -p "$DEST"
  for skill_md in "$REPO"/skills/*/SKILL.md; do
    src="$(dirname "$skill_md")"; name="$(basename "$src")"; target="$DEST/$name"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "skip  $name: $target is a real directory, remove it first to link" >&2; continue
    fi
    ln -sfn "$src" "$target"
    if [ -L "$target" ]; then echo "link  $name -> $src  ($DEST)"
    else echo "warn  $name: $target is a COPY, not a link (enable Developer Mode on Windows)" >&2; fi
  done
done
