#!/bin/bash

# Check if directory is provided
if [ -z "$1" ]; then
    echo "Usage: ./rename.sh <directory_path> [out_directory_path]"
    exit 1
fi

directory="$1"
out_directory="$2"

# Check if input directory exists
if [ ! -d "$directory" ]; then
    echo "The directory $directory does not exist."
    exit 1
fi

# Create output directory if specified
if [ ! -z "$out_directory" ]; then
    mkdir -p "$out_directory"
fi

# Count total files for progress
total_files=$(find "$directory" -maxdepth 1 -name "*.Replay.gbx" | wc -l)
processed=0
progress_interval=$((total_files / 10))

# Process each file
find "$directory" -maxdepth 1 -name "*.Replay.gbx" | while read -r file; do
    filename=$(basename "$file")
    base_name="${filename%.Replay.gbx}"
    
    # Replace spaces with underscores
    new_filename="${base_name// /_}"
    
    # Remove color codes and special characters
    new_filename=$(echo "$new_filename" | sed -E 's/\$[ghijkmnopqrstuvwxyzGHIJKMNOPQRSTUVWXYZ]//g')
    new_filename=$(echo "$new_filename" | sed -E 's/\$[lL]\[.*?\]//g')
    new_filename=$(echo "$new_filename" | sed 's/\$l//g')
    new_filename=$(echo "$new_filename" | sed -E 's/\$[0-9a-zA-Z_]{3}//g')
    new_filename=$(echo "$new_filename" | sed 's/\$\$/\$/g')
    new_filename=$(echo "$new_filename" | sed -E 's/_{2,}/_/g')
    
    # Show progress
    processed=$((processed + 1))
    if [ $total_files -gt 10 ] && [ $((processed % progress_interval)) -eq 0 ]; then
        percentage=$((processed * 100 / total_files))
        echo "Processed $percentage% of files."
    fi
    
    # Handle file operations
    index=1
    base_path=""

    if [ ! -z "$out_directory" ]; then
        base_path="$out_directory"
        operation="cp"
    else
        base_path="$directory"
        operation="mv"
    fi

    destination_path="$base_path/$new_filename.Replay.gbx"
    while [ -e "$destination_path" ]; do
        destination_path="$base_path/${new_filename}_$index.Replay.gbx"
            index=$((index + 1))
    done
    $operation "$file" "$destination_path"
done

# Print success message
if [ ! -z "$out_directory" ]; then
    echo "Successfully renamed all files from $directory and saved them to $out_directory"
else
    echo "Successfully renamed all files from $directory"
fi