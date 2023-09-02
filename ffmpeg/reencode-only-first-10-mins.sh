#!/bin/bash

search_dir=`pwd`

for entry in "$search_dir"/*.mp4
do
    filename_with_extension="${entry##*/}"
    extension="${filename_with_extension##*.}"
    filename_without_extension="${filename_with_extension%.*}"
    echo "$filename_with_extension"
    echo "$filename_without_extension"_extract.mp4
    ffmpeg -i "$filename_with_extension" -ss 00:00:00 -to 00:10:00 "$filename_without_extension"_extract.mp4
done
