#!/bin/bash

yt-dlp -f 'bestvideo[height=480]+bestaudio[ext=m4a],
           bestvideo[height=720]+bestaudio[ext=m4a],
           bestvideo[height=1080]+bestaudio[ext=m4a],
           bestvideo[height=1440]+bestaudio[ext=m4a],
           bestvideo[height=2160]+bestaudio[ext=m4a],
           bestvideo[height=4320]+bestaudio[ext=m4a],
           bestvideo+bestaudio[ext=m4a]/best[ext=mp4]/best' \
  --merge-output-format mp4 \
  --embed-metadata \
  --embed-thumbnail \
  --retries 100 \
  --min-sleep-interval 3 \
  --max-sleep-interval 10 \
  --output "%(uploader)s - %(upload_date>%Y-%m-%d)s - %(title)s [%(id)s] (%(resolution)s).%(ext)s" \
  -- "$@"
