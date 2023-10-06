#!/bin/bash

# https://stackoverflow.com/a/40659337/4625758

search_dir=`pwd`

for entry in "$search_dir"/*.mkv
do
    filename_with_extension="${entry##*/}"
    extension="${filename_with_extension##*.}"
    filename_without_extension="${filename_with_extension%.*}"
    echo "$filename_with_extension"
    echo "$filename_without_extension"_copied.mp4
    ffmpeg -i "$filename_with_extension" -c copy -map 0:v -map 0:m:language:eng "$filename_without_extension"_copied.mp4
done
