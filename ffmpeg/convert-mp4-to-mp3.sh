#!/bin/bash

search_dir=`pwd`

for entry in "$search_dir"/*.mp4
do
    filename_with_extension="${entry##*/}"
    extension="${filename_with_extension##*.}"
    filename_without_extension="${filename_with_extension%.*}"
    echo "$filename_with_extension"
    echo "$filename_without_extension".mp3
    ffmpeg -i "$filename_with_extension" -vn -acodec libmp3lame -ac 2 -ab 192k -ar 48000 "$filename_without_extension".mp3
done
