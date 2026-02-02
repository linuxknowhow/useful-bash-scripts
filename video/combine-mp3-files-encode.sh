#!/bin/bash

# Check if the number of parameters is correct
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <bitrate> <input_directory>"
    exit 1
fi

# Bitrate parameter
bitrate="$1"

# Specify the directory containing the MP3 files
input_dir="$2"

# Specify the output file name
output_file="combined.mp3"

# Change directory to the input directory
cd "$input_dir" || exit

# Use ffmpeg to concatenate the MP3 files
ffmpeg -i "concat:$(printf "%s|" *.mp3)" -vn -acodec libmp3lame -ac 2 -ab "${bitrate}k" -ar 48000 "$output_file"

echo "Combination complete. Output file: $output_file"
