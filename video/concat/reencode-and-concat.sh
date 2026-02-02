#!/bin/bash

search_dir=`pwd`

for entry in "$search_dir"/*.mp4
do
    filename_with_extension="${entry##*/}"
    extension="${filename_with_extension##*.}"
    filename_without_extension="${filename_with_extension%.*}"
    echo "$filename_with_extension"
    echo "$filename_without_extension"_reencoded.mp4
    ffmpeg -i "$filename_with_extension" -acodec libmp3lame -ac 2 -ab 320k -ar 48000 -vcodec libx264 -s 1280x720 -r 60 -b:v 6M "$filename_without_extension"_reencoded.mp4
done

ffmpeg -f concat -safe 0 -i mylist.txt -acodec libmp3lame -ac 2 -ab 320k -ar 48000 -vcodec libx264 -s 1280x720 -r 60 -b:v 6M -vf select=concatdec_select -af aselect=concatdec_select,aresample=async=1 output.mp4
