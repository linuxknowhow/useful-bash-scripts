#!/bin/bash

search_dir=`pwd`

for entry in "$search_dir"/*.mp4
do
    filename_with_extension="${entry##*/}"
    ffprobe "$filename_with_extension" -show_entries stream=index:stream_tags=language -select_streams a -of compact=p=0:nk=1
done
