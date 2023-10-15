#!/bin/bash

BIN="firefox-bin"

if pgrep -x "$BIN" >/dev/null
  then
    echo "Firefox is running"
  else
    rm -rf ~/.cache/mozilla/firefox/*
fi
