#!/bin/bash

# Directory containing the files
DIRECTORY=$1

# Temporary directory for sparse files
TEMP_DIR=$2

# Create the temporary directory if it doesn't exist
mkdir -p "$TEMP_DIR"

# Find all files in the directory and convert them to sparse files
find "$DIRECTORY" -type f | while read file; do
    echo "$file"
    echo "$TEMP_DIR/$(basename "$file").sparse"
    # Create a sparse copy of the file
    cp --sparse=always "$file" "$TEMP_DIR/$(basename "$file").sparse"

    # Move the sparse file back to the original location
    mv "$TEMP_DIR/$(basename "$file").sparse" "$file"
done

# Clean up the temporary directory
rm -rf "$TEMP_DIR"
