#!/bin/bash
# combine-vob-files.sh
# Combines split VOB files (VTS_XX_1.VOB, VTS_XX_2.VOB...) into a single VOB file per title set.
# Uses 'cat' which is sufficient for MPEG-PS stream concatenation, though timestamp discontinuities may occur.

set -euo pipefail

# Work in current directory or argument
TARGET_DIR="${1:-$(pwd)}"

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

cd "$TARGET_DIR"

echo "Scanning for VOB title sets in: $(pwd)"

# Identify title sets by looking for the first video part (ends in _1.VOB)
# We use case-insensitive globbing to handle .VOB, .vob, etc.
shopt -s nocaseglob nullglob

# Use associative array to dedup prefixes (handles filenames with spaces correctly)
declare -A FOUND_PREFIXES

# Find all files ending in _1.VOB (case insensitive)
START_FILES=(*_1.VOB)

if [[ ${#START_FILES[@]} -eq 0 ]]; then
    echo "No standard DVD video parts (*_1.VOB) found."
    exit 0
fi

for FILE in "${START_FILES[@]}"; do
    # Strip the last 6 characters (_1.VOB) to get the prefix (e.g., VTS_01)
    # This also handles case (strips _1.VOB or _1.vob etc because glob matched it)
    PREFIX="${FILE:0:-6}"
    FOUND_PREFIXES["$PREFIX"]=1
done

# Sort prefixes for clean output (associative arrays are unordered)
# We map keys to array, then sort
PREFIX_LIST=("${!FOUND_PREFIXES[@]}")
mapfile -t SORTED_PREFIXES < <(printf '%s\n' "${PREFIX_LIST[@]}" | sort -V)

for PREFIX in "${SORTED_PREFIXES[@]}"; do
    OUTPUT_FILE="${PREFIX}_COMBINED.VOB"
    
    echo "--------------------------------------------------------"
    echo "Processing Title Set: $PREFIX"
    
    # Find all parts for this prefix (matching PREFIX_[1-9]*.VOB)
    # This pattern matches _1.VOB, _2.VOB, _10.VOB but ignores _0.VOB (Menu)
    # Because of nocaseglob, this matches .vob and .VOB
    MATCHING_FILES=("${PREFIX}"_[1-9]*.VOB)

    if [[ ${#MATCHING_FILES[@]} -eq 0 ]]; then
        echo "  No video parts found (odd, since we found part 1)."
        continue
    fi

    # Natural sort so 1, 2, 10 order is correct
    mapfile -t FILE_LIST < <(printf '%s\n' "${MATCHING_FILES[@]}" | sort -V)
    COUNT=${#FILE_LIST[@]}
    
    echo "  Found $COUNT parts: ${FILE_LIST[*]}"
    
    if [[ -f "$OUTPUT_FILE" ]]; then
        echo "  Warning: Output file '$OUTPUT_FILE' already exists. Skipping."
        continue
    fi
    
    echo "  Concatenating into '$OUTPUT_FILE'..."
    
    # Use cat to combine files binary-wise
    cat "${FILE_LIST[@]}" > "$OUTPUT_FILE"
    
    echo "  Success: Created '$OUTPUT_FILE'"
done

echo "--------------------------------------------------------"
echo "All done."
