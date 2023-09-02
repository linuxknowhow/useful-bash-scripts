#!/bin/bash

search_dir=`pwd`

for entry in "$search_dir"/*.mkv
do
    filename_with_extension="${entry##*/}"
    extension="${filename_with_extension##*.}"
    filename_without_extension="${filename_with_extension%.*}"
    echo "$filename_with_extension"
    echo "$filename_without_extension"_copied.mp4
    ffmpeg -i "$filename_with_extension" -map 0:v:0 -map 0:a:1 -map 0:s:0 -c:a copy -c:v copy -c:s mov_text -map_metadata -1 "$filename_without_extension"_copied.mp4
done
