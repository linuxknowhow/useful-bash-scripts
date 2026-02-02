#!/bin/bash
# fix-combined-vob.sh
# Scans for *_COMBINED.VOB files (created by combine-vob-files.sh) and remuxes them
# using ffmpeg to correct timestamp discontinuities caused by binary concatenation.

set -euo pipefail

# Work in current directory or argument
TARGET_DIR="${1:-$(pwd)}"

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

cd "$TARGET_DIR"

echo "Scanning for combined VOB files (*_COMBINED.VOB) in: $(pwd)"

shopt -s nullglob
FILES=(*_COMBINED.VOB)

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "No '*_COMBINED.VOB' files found."
    echo "Run 'combine-vob-files.sh' first, or rename your files."
    exit 0
fi

for FILE in "${FILES[@]}"; do
    # Define output name, e.g., VTS_01_COMBINED.VOB -> VTS_01_FIXED.VOB
    BASENAME="${FILE%_COMBINED.VOB}"
    OUTPUT_FILE="${BASENAME}_FIXED.VOB"
    
    echo "--------------------------------------------------------"
    echo "Processing: $FILE"
    
    if [[ -f "$OUTPUT_FILE" ]]; then
        echo "  Warning: Output file '$OUTPUT_FILE' already exists. Skipping."
        continue
    fi
    
    echo "  Remuxing to fix timestamps..."
    
    # -fflags +genpts: Generate new Presentation TimeStamps (PTS) based on decoding
    # -map 0:v -map 0:a -map 0:s?: Map video, audio, and optional subtitles. 
    #   We AVOID '-map 0' because VOBs often contain data streams (DVD navigation)
    #   that ffmpeg's VOB muxer cannot write, causing "Invalid media type data".
    # -c copy: Stream copy mode (no quality loss, very fast)
    # -f vob: Force VOB container format
    ffmpeg -hide_banner -loglevel error -stats \
        -fflags +genpts \
        -i "$FILE" \
        -map "0:v" -map "0:a" -map "0:s?" \
        -c copy \
        -f vob \
        "$OUTPUT_FILE"
    
    echo "" # Newline after ffmpeg stats
    echo "  Success: Created '$OUTPUT_FILE'"
done

echo "--------------------------------------------------------"
echo "All done."
