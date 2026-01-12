#!/bin/bash

# ------------------------------------------------------------------------------
# secure-wipe-vps.sh
# ------------------------------------------------------------------------------
# Purpose: Best-effort data destruction from inside a running VPS prior to
# provider-side termination. The script automatically targets all user data
# directories while preserving critical system paths required to complete the
# wipe operation:
#   - Stops all non-essential services (databases, web servers, apps, Docker)
#   - Automatically shreds all non-system directories (/home, /root, /var, /opt, etc.)
#   - Clears logs, temp, and package caches
#   - Disables and overwrites swap (file or partition)
#   - Overwrites free space on relevant filesystems (zeros) to reduce recovery
#
# Notes and warnings:
#   - Run as root on Linux only. This is destructive.
#   - On SSDs, thin-provisioned or cloud-backed volumes, overwrites may not be
#     perfect; still destroy the VPS/volume via your provider afterward.
#   - Running on the live root filesystem will make the node unstable; expect
#     slow performance and possible I/O errors while wiping.
#   - After completion: poweroff the VPS, then destroy it in the provider panel.
# ------------------------------------------------------------------------------

set -euo pipefail

# System directories that must be preserved to keep the system running during wipe
PROTECTED_PATHS=(
  "/bin"
  "/sbin"
  "/lib"
  "/lib64"
  "/lib32"
  "/usr"
  "/boot"
  "/dev"
  "/proc"
  "/sys"
  "/run"
  "/etc"        # System config - preserve to keep shell/commands working
  "/lost+found"
)

# Build target list: all top-level directories except protected ones
build_targets() {
  local targets=()
  local script_dir
  script_dir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
  
  # Add all top-level directories except protected
  for d in /*; do
    [[ -d "$d" ]] || continue
    local skip=false
    for p in "${PROTECTED_PATHS[@]}"; do
      if [[ "$d" == "$p" ]]; then
        skip=true
        break
      fi
    done
    # Skip directory containing this script
    if [[ "$d" == "$script_dir" || "$script_dir" == "$d"* ]]; then
      skip=true
    fi
    [[ $skip == false ]] && targets+=("$d")
  done
  
  echo "${targets[@]}"
}

TARGETS=($(build_targets))
SHRED_PASSES=3
ZERO_FILL_NAME=".wipe_zero_fill.bin"

log() { echo "[*] $*"; }
warn() { echo "[!] $*" >&2; }

require_root() {
  if [[ $(id -u) -ne 0 ]]; then
    warn "Run as root."; exit 1;
  fi
}

confirm() {
  warn "This will irreversibly wipe data on this VPS.";
  read -rp "Type WIPE to continue: " ans
  [[ "$ans" == "WIPE" ]] || { warn "Aborted."; exit 1; }
}

stop_services() {
  log "Stopping non-essential services"
  
  # Essential services to keep running
  local KEEP_RUNNING=(
    "systemd"
    "ssh"
    "sshd"
    "network"
    "NetworkManager"
    "systemd-networkd"
    "systemd-resolved"
    "systemd-journald"
    "systemd-logind"
    "systemd-udevd"
    "dbus"
    "cron"
    "rsyslog"
  )
  
  # Get list of running services
  local services
  services=$(systemctl list-units --type=service --state=running --no-legend 2>/dev/null | awk '{print $1}' | sed 's/\.service$//')
  
  for svc in $services; do
    # Check if this service should be kept running
    local keep=false
    for essential in "${KEEP_RUNNING[@]}"; do
      if [[ "$svc" == "$essential" || "$svc" == *"$essential"* ]]; then
        keep=true
        break
      fi
    done
    
    if [[ $keep == false ]]; then
      log "Stopping service: $svc"
      systemctl stop "$svc" 2>/dev/null || true
    fi
  done
  
  # Stop Docker if present
  if command -v docker >/dev/null 2>&1; then
    log "Stopping all Docker containers"
    docker stop $(docker ps -aq) 2>/dev/null || true
  fi
}

shred_targets() {
  local script_path
  script_path=$(readlink -f "${BASH_SOURCE[0]}")
  
  for d in "${TARGETS[@]}"; do
    if [[ -d "$d" ]]; then
      log "Shredding files under $d"
      find "$d" -type f -print0 | while IFS= read -r -d '' f; do
        [[ -f "$f" ]] || continue
        # Skip the script itself and shred binary
        if [[ "$f" == "$script_path" || "$f" == "$(command -v shred)" ]]; then
          continue
        fi
        shred -u -v -n "$SHRED_PASSES" "$f" 2>/dev/null || true
      done
      log "Removing empty directories under $d"
      find "$d" -type d -empty -delete 2>/dev/null || true
    else
      log "Skip (not found): $d"
    fi
  done
}

clean_system() {
  log "Cleaning caches and temp"
  command -v apt-get >/dev/null 2>&1 && apt-get clean || true
  command -v yum >/dev/null 2>&1 && yum clean all || true
  rm -rf /tmp/* /var/tmp/* || true
  log "Truncating logs"
  if [[ -d /var/log ]]; then
    find /var/log -type f -exec truncate -s 0 {} \; || true
  fi
  if command -v journalctl >/dev/null 2>&1; then
    journalctl --rotate || true
    journalctl --vacuum-time=1s || true
  fi
}

disable_and_wipe_swap() {
  log "Disabling swap"
  swapoff -a || true

  if [[ -f /swapfile ]]; then
    log "Wiping swapfile /swapfile"
    dd if=/dev/zero of=/swapfile bs=1M status=progress || true
    sync
    rm -f /swapfile || true
    sync
  fi

  awk '/^\/dev/ {print $1}' /proc/swaps | while read -r sw; do
    [[ -b "$sw" ]] || continue
    log "Wiping swap partition $sw"
    dd if=/dev/zero of="$sw" bs=1M status=progress || true
    sync
  done
}

fill_free_space_on_mount() {
  local mp="$1"
  local filler="$mp/$ZERO_FILL_NAME"
  [[ -d "$mp" ]] || return 0
  log "Filling free space on $mp with zeros (may take time)"
  dd if=/dev/zero of="$filler" bs=1M status=progress || true
  sync
  rm -f "$filler" || true
  sync
}

wipe_free_space() {
  declare -A SEEN=()
  local paths=("/" "/home" "${TARGETS[@]}")
  for p in "${paths[@]}"; do
    [[ -e "$p" ]] || continue
    local mp
    mp=$(df -P "$p" 2>/dev/null | awk 'NR==2 {print $6}') || true
    [[ -n "$mp" && -d "$mp" && -z "${SEEN[$mp]:-}" ]] || continue
    SEEN["$mp"]=1
    fill_free_space_on_mount "$mp"
  done
}

main() {
  require_root
  confirm
  stop_services
  shred_targets
  clean_system
  disable_and_wipe_swap
  wipe_free_space
  log "Final sync"
  sync
  warn "Done. Power off the VPS, then destroy it from the provider console." 
}

main "$@"
