#!/bin/bash

# ------------------------------------------------------------------------------
# delete-chrome-storage.sh
# ------------------------------------------------------------------------------
# Remove Google Chrome per-site persistent storage on Linux (IndexedDB,
# local/session storage, Service Worker data, Cache API blobs, File System API
# data, etc.). This is not the regular disk cache or browsing history—clearing
# it fixes broken PWAs, frees disk space, or resets sticky site settings/logins.
# Only storage directories inside each Chrome profile are purged; cache,
# history, cookies, and the rest of the profile remain intact. Chrome must be
# closed before running this script.
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

# Relative storage paths considered safe to purge (per profile).
readonly STORAGE_PATHS=(
	"IndexedDB"
	"Local Storage"
	"Session Storage"
    "Service Worker"
    "Service Worker/Database"
    "Service Worker/CacheStorage"
    "Service Worker/ScriptCache"
	"Application Cache"
	"databases"
	"QuotaManager"
	"QuotaManager-journal"
	"QuotaManager-wal"
	"File System"
	"File System Origins"
	"SharedPreferences"
	"Storage"
)

shopt -s nullglob
profile_dirs=(
	"$PROFILE_ROOT"/Default
	"$PROFILE_ROOT"/Profile\ *
	"$PROFILE_ROOT"/Guest\ Profile
)

found_profile=false
for profile in "${profile_dirs[@]}"; do
	[[ -d "$profile" ]] || continue
	found_profile=true
	echo "Clearing Chrome storage for profile: $profile"

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
	echo "No Chrome profiles containing storage directories were found under '$PROFILE_ROOT'."
else
	echo "Chrome site storage cleanup complete."
fi
