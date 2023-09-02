#!/bin/bash

search_dir=`pwd`

for entry in "$search_dir"/*.gif
do
    filename_with_extension="${entry##*/}"
    extension="${filename_with_extension##*.}"
    filename_without_extension="${filename_with_extension%.*}"
    echo "$filename_with_extension"
    echo "$filename_without_extension".mp4
    ffmpeg -i "$filename_with_extension" -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" "$filename_without_extension".mp4
done
