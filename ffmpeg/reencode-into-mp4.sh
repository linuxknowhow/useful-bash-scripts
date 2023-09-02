#!/bin/bash

search_dir=`pwd`

for entry in "$search_dir"/*.avi
do
    filename_with_extension="${entry##*/}"
    extension="${filename_with_extension##*.}"
    filename_without_extension="${filename_with_extension%.*}"
    echo "$filename_with_extension"
    echo "$filename_without_extension"_reencoded.mp4
    ffmpeg -i "$filename_with_extension" -c:v libx264 -b:v 5M -b:a 192k -brand mp42 -vf format=yuv420p -movflags +faststart "$filename_without_extension"_reencoded.mp4
done