#!/bin/bash

# This produces very low quality jpgs
# Fuck webp, it's a ridiculous format

# To redo it using this?
# https://superuser.com/a/1444008/1727772
# or this?
# https://stackoverflow.com/a/49592591/4625758

search_dir=`pwd`

for entry in "$search_dir"/*.webp
do
    filename_with_extension="${entry##*/}"
    extension="${filename_with_extension##*.}"
    filename_without_extension="${filename_with_extension%.*}"
    echo "$filename_with_extension"
    echo "$filename_without_extension".jpg
    ffmpeg -i "$filename_with_extension" "$filename_without_extension".jpg
done
