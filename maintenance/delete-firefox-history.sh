#!/bin/bash

# ------------------------------------------------------------------------------
# delete-firefox-history.sh
# ------------------------------------------------------------------------------
# Safely delete Mozilla Firefox browsing-history databases on Linux. The script
# removes only history-related SQLite databases (bookmarks/history storage) and
# leaves cache, cookies, and other profile data untouched. Firefox must be
# closed before running this script.
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

# Files that store browsing history and related metadata.
readonly HISTORY_FILES=(
  "places.sqlite"
  "places.sqlite-wal"
  "places.sqlite-shm"
  "favicons.sqlite"
  "favicons.sqlite-wal"
  "favicons.sqlite-shm"
  "formhistory.sqlite"
  "formhistory.sqlite-wal"
  "formhistory.sqlite-shm"
  "sessionstore.jsonlz4"
  "sessionstore-backups"
)

shopt -s nullglob
profile_dirs=( "$PROFILE_ROOT"/* )

found_profile=false
for profile in "${profile_dirs[@]}"; do
  [[ -d "$profile" ]] || continue
  found_profile=true
  echo "Clearing Firefox history for profile: $profile"
  for item in "${HISTORY_FILES[@]}"; do
    target="$profile/$item"
    if [[ -e "$target" ]]; then
      rm -rf -- "$target"
      echo "  ✔ Removed: $target"
    fi
  done
done

if [[ $found_profile == false ]]; then
  echo "No Firefox profiles containing history files were found under '$PROFILE_ROOT'."
else
  echo "Firefox history cleanup complete."
fi
