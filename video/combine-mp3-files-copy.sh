#!/bin/bash

# Specify the directory containing the MP3 files
input_dir=`pwd`

# Specify the output file name
output_file="combined.mp3"

# Change directory to the input directory
cd "$input_dir" || exit

# Use ffmpeg to concatenate the MP3 files
ffmpeg -i "concat:$(printf "%s|" *.mp3)" -c copy "$output_file"

echo "Combination complete. Output file: $output_file"
