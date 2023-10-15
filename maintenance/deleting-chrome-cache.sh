#!/bin/bash

BIN="chrome"

if pgrep -x "$BIN" >/dev/null
  then
    echo "Chrome is running"
  else
    rm -rf ~/.cache/google-chrome

    rm -rf ~/.config/google-chrome/Default/IndexedDB/*

    truncate --size 0 ~/.config/google-chrome/Default/History ~/.config/google-chrome/Default/History-journal ~/.config/google-chrome/Default/Media\ History ~/.config/google-chrome/Default/Media\ History-journal
fi
