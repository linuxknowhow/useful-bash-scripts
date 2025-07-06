#!/bin/bash

yt-dlp -i \
  --extract-audio \
  --audio-format mp3 \
  --audio-quality 0 \
  --embed-metadata \
  --embed-thumbnail \
  --retries 100 \
  --min-sleep-interval 3 \
  --max-sleep-interval 10 \
  --output "%(uploader)s - %(upload_date>%Y-%m-%d)s - %(title)s [%(id)s].%(ext)s" \
  -- "$@"
