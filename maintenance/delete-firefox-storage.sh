#!/bin/bash

# ------------------------------------------------------------------------------
# delete-firefox-storage.sh
# ------------------------------------------------------------------------------
# Remove Mozilla Firefox per-site persistent storage on Linux. This includes
# IndexedDB, localStorage, Service Worker caches, Cache API blobs, WebExtension
# storage, and other large offline assets that live under storage/default. This
# data is not the regular disk cache or browsing history; wiping it helps fix
# broken web apps, reclaim space, or reset sticky site settings/logins. Only the
# storage directories inside each Firefox profile are purged—cache, history,
# cookies, and other profile data remain untouched. Firefox must be closed
# before running this script.
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

readonly PROFILE_ROOT="$HOME/.mozilla/firefox"

if [[ ! -d "$PROFILE_ROOT" ]]; then
  echo "Nothing to do: Firefox profile directory '$PROFILE_ROOT' not found." >&2
  exit 0
fi

clear_storage_target() {
  local target="$1"
  if [[ -d "$target" ]]; then
    rm -rf -- "$target"
    mkdir -p -- "$target"
    return
  fi
  if [[ -e "$target" ]]; then
    rm -f -- "$target"
  fi
}

# Relative storage paths we consider safe to wipe.
readonly STORAGE_PATHS=(
  "storage/default"
  "storage/temporary"
  "storage/permanent"
  "storage/ls-archive"
  "storage/ls-archive.tmp"
  "storage/default/cache"
  "storage/default/https+++*"
)

shopt -s nullglob
profile_dirs=( "$PROFILE_ROOT"/* )

found_profile=false
for profile in "${profile_dirs[@]}"; do
  [[ -d "$profile" ]] || continue
  found_profile=true
  echo "Clearing Firefox storage for profile: $profile"

  for rel in "${STORAGE_PATHS[@]}"; do
    matches=( "$profile"/$rel )
    for target in "${matches[@]}"; do
      if [[ -e "$target" ]]; then
        clear_storage_target "$target"
        echo "  ✔ Removed: $target"
      fi
    done
  done
done

if [[ $found_profile == false ]]; then
  echo "No Firefox profiles containing storage directories were found under '$PROFILE_ROOT'."
else
  echo "Firefox site storage cleanup complete."
fi
