#!/bin/bash

yt-dlp --output "%(uploader)s - %(upload_date>%Y-%m-%d)s - %(title)s [%(id)s].%(ext)s" -- "$@"
