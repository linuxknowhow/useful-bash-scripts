#!/bin/bash

yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio/best[ext=mp4]/best' \
  --merge-output-format mp4 \
  --retries 100 \
  --min-sleep-interval 3 \
  --max-sleep-interval 10 \
  --cookies-from-browser firefox \
  --output "%(uploader).50B - %(upload_date>%Y-%m-%d)s - %(title).100B [%(id)s].%(ext)s" \
  -- "$@"
