#!/bin/bash

search_dir=`pwd`

for entry in "$search_dir"/*.mp4
do
    filename=$(basename -- "$entry")
    echo "$filename"
done