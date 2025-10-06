#!/bin/bash

yt-dlp \
  -f 'best[height>=720]' \
  --concurrent-fragments 5 \
  --cookies-from-browser firefox \
  --retries 100 \
  --min-sleep-interval 3 \
  --max-sleep-interval 10 \
  --output "%(uploader).50B - %(upload_date>%Y-%m-%d)s - %(title).100B [%(id)s].%(ext)s" \
  -- "$@"
