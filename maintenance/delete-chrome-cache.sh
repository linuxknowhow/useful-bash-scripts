#!/bin/bash

# ------------------------------------------------------------------------------
# delete-chrome-cache.sh
# ------------------------------------------------------------------------------
# Safely delete Google Chrome cache data on Linux. The script removes only cache
# directories/files and leaves browsing history, cookies, and other profile data
# untouched. Chrome must not be running while the script operates.
# ------------------------------------------------------------------------------

set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Error: This script is intended for Linux systems only." >&2
  exit 1
fi

# Chrome binary names we consider
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

clear_path() {
  local target="$1"
  if [[ -e "$target" ]]; then
    rm -rf -- "$target"
  fi
  mkdir -p -- "$target"
}

# Explicit list of cache-only locations.
readonly CACHE_TARGETS=(
  "$HOME/.cache/google-chrome"
  "$HOME/.config/google-chrome/ShaderCache"
  "$HOME/.config/google-chrome/GrShaderCache"
  "$HOME/.config/google-chrome/Default/Cache"
  "$HOME/.config/google-chrome/Default/Code Cache"
  "$HOME/.config/google-chrome/Default/GPUCache"
  "$HOME/.config/google-chrome/Default/Service Worker/CacheStorage"
  "$HOME/.config/google-chrome/Default/Application Cache"
  "$HOME/.config/google-chrome/Default/Media Cache"
)

echo "Clearing Google Chrome cache directories..."

for path in "${CACHE_TARGETS[@]}"; do
  clear_path "$path"
  echo "✔ Cleaned: $path"
done

echo "Chrome cache cleanup complete."
