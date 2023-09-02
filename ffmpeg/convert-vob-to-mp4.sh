#!/bin/bash

search_dir=`pwd`

for entry in "$search_dir"/*.vob
do
    filename_with_extension="${entry##*/}"
    extension="${filename_with_extension##*.}"
    filename_without_extension="${filename_with_extension%.*}"
    echo "$filename_with_extension"
    echo "$filename_without_extension".mp4
    ffmpeg -i "$filename_with_extension" "$filename_without_extension".mp4
done
