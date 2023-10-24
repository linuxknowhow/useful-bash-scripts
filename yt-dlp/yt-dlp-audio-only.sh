#!/bin/bash

yt-dlp -i --extract-audio --audio-format mp3 --audio-quality 0 --output "%(uploader)s - %(upload_date>%Y-%m-%d)s - %(title)s [%(id)s].%(ext)s" -- "$@"
