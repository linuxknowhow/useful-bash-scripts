#!/bin/bash

yt-dlp -f 'bestvideo[height<=480]+bestaudio/best[height<=480]' --merge-output-format mp4 --output "%(uploader)s - %(upload_date>%Y-%m-%d)s - %(title)s [%(id)s] (Mobile).%(ext)s" -- "$@"
