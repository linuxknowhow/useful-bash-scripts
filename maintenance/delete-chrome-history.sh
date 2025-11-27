#!/bin/bash

# ------------------------------------------------------------------------------
# delete-chrome-history.sh
# ------------------------------------------------------------------------------
# Safely delete Google Chrome browsing-history databases on Linux. The script
# removes history-related SQLite databases only (no cache, cookies, or other
# profile data) and requires Chrome to be closed beforehand.
# ------------------------------------------------------------------------------

set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
	echo "Error: This script is intended for Linux systems only." >&2
	exit 1
fi

readonly CHROME_PROCESSES=("chrome" "google-chrome" "google-chrome-stable")

is_chrome_running() {
	for bin in "${CHROME_PROCESSES[@]}"; do
		if pgrep -x "$bin" >/dev/null 2>&1; then
			return 0
		fi
	done
	return 1
}

if is_chrome_running; then
	echo "Error: Google Chrome appears to be running. Please close it and rerun." >&2
	exit 1
fi

readonly PROFILE_ROOT="$HOME/.config/google-chrome"

if [[ ! -d "$PROFILE_ROOT" ]]; then
	echo "Nothing to do: Chrome profile directory '$PROFILE_ROOT' not found." >&2
	exit 0
fi

# History databases we target inside each profile directory.
readonly HISTORY_FILES=(
	"History"
	"History-journal"
	"History Provider Cache"
	"History Provider Cache-journal"
	"Visited Links"
	"Visited Links-journal"
	"Network Action Predictor"
	"Top Sites"
	"Top Sites-journal"
	"Shortcuts"
	"Shortcuts-journal"
	"Media History"
	"Media History-journal"
)

shopt -s nullglob
profile_dirs=(
	"$PROFILE_ROOT"/Default
	"$PROFILE_ROOT"/Profile\ *
	"$PROFILE_ROOT"/Guest\ Profile
)

found_profile=false
for profile in "${profile_dirs[@]}"; do
	if [[ -d "$profile" ]]; then
		found_profile=true
		echo "Clearing history for profile: $profile"
		for file in "${HISTORY_FILES[@]}"; do
			target="$profile/$file"
			if [[ -e "$target" ]]; then
				rm -f -- "$target"
				echo "  ✔ Deleted: $target"
			fi
		done
	fi
done

if [[ $found_profile == false ]]; then
	echo "No Chrome profiles with history databases were found under '$PROFILE_ROOT'."
else
	echo "Chrome history cleanup complete."
fi
