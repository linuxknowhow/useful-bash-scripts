#!/bin/bash

yt-dlp \
  -f 'best[height>=720]' \
  --concurrent-fragments 5 \
  --cookies-from-browser firefox \
  --embed-thumbnail \
  --embed-metadata \
  --retries 100 \
  --min-sleep-interval 3 \
  --max-sleep-interval 10 \
  --output "%(uploader)s - %(upload_date>%Y-%m-%d)s - %(title)s [%(id)s].%(ext)s" \
  -- "$@"
