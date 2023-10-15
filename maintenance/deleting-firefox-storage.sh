#!/bin/bash

BIN="firefox-bin"

if pgrep -x "$BIN" >/dev/null
  then
    echo "Firefox is running"
  else
    rm -rf ~/.cache/mozilla/firefox/*

    search_dir=~/.mozilla/firefox

    for profile in "$search_dir"/*
    do
    	#echo "$profile"
        basename=$(basename -- "$profile")

	# Ignoring if empty folder
        if [[ "$basename" = "*" ]];
    	    then continue;
    	fi

        storage="$profile/storage/default/"

        if [ -d "$storage" ]; then
            # echo "$storage"
            rm -rf "$storage"/*
        fi
    done
fi
