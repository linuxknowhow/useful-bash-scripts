#!/bin/bash

# ------------------------------------------------------------------------------
# delete-firefox-cache.sh
# ------------------------------------------------------------------------------
# Safely delete Mozilla Firefox cache data on Linux. The script removes only
# cache directories/files and leaves history, cookies, and other profile data
# untouched. Firefox must not be running while the script operates.
# ------------------------------------------------------------------------------

set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Error: This script is intended for Linux systems only." >&2
  exit 1
fi

readonly FIREFOX_PROCESSES=("firefox" "firefox-bin" "firefox-esr" "firefox-nightly")

is_firefox_running() {
  for bin in "${FIREFOX_PROCESSES[@]}"; do
    if pgrep -x "$bin" >/dev/null 2>&1; then
      return 0
    fi
  done
  return 1
}

if is_firefox_running; then
  echo "Error: Firefox appears to be running. Please close it and rerun." >&2
  exit 1
fi

clear_path() {
  local target="$1"
  if [[ -e "$target" ]]; then
    rm -rf -- "$target"
  fi
  mkdir -p -- "$target"
}

echo "Clearing Firefox cache directories..."

# Global cache (per XDG cache spec)
GLOBAL_CACHE="$HOME/.cache/mozilla/firefox"
clear_path "$GLOBAL_CACHE"
echo "✔ Cleaned: $GLOBAL_CACHE"

PROFILE_ROOT="$HOME/.mozilla/firefox"
if [[ -d "$PROFILE_ROOT" ]]; then
  shopt -s nullglob
  profile_dirs=( "$PROFILE_ROOT"/* )
  for profile in "${profile_dirs[@]}"; do
    [[ -d "$profile" ]] || continue
    cache_paths=(
      "$profile/cache2"
      "$profile/startupCache"
      "$profile/jumpListCache"
      "$profile/offlineCache"
    )
    for cache_dir in "${cache_paths[@]}"; do
      if [[ -e "$cache_dir" ]]; then
        clear_path "$cache_dir"
        echo "✔ Cleaned: $cache_dir"
      fi
    done
  done
else
  echo "Firefox profile directory '$PROFILE_ROOT' not found; skipped per-profile caches."
fi

echo "Firefox cache cleanup complete."
