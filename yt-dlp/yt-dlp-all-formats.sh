#!/bin/bash

yt-dlp -f 'bestvideo[height=480]+bestaudio[ext=m4a],
           bestvideo[height=720]+bestaudio[ext=m4a],
           bestvideo[height=1080]+bestaudio[ext=m4a],
           bestvideo[height=1440]+bestaudio[ext=m4a],
           bestvideo[height=2160]+bestaudio[ext=m4a],
           bestvideo[height=4320]+bestaudio[ext=m4a],
           bestvideo+bestaudio[ext=m4a]/best[ext=mp4]/best' \
  --merge-output-format mp4 \
  --retries 100 \
  --min-sleep-interval 3 \
  --max-sleep-interval 10 \
  --output "%(uploader).50B - %(upload_date>%Y-%m-%d)s - %(title).100B [%(id)s] (%(resolution)s).%(ext)s" \
  -- "$@"
