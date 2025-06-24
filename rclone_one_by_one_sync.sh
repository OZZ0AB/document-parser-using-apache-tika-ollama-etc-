#!/bin/bash

LOCAL_DIR="/home/server-admin/document_pipeline/input"
REMOTE_INPUT="document_pipeline:input"
REMOTE_ARCHIVE="document_pipeline:archive/input"

# Create a temp folder to hold one file at a time locally
TMP_LOCAL="/tmp/rclone_temp_sync"
mkdir -p "$TMP_LOCAL"

# List files in remote input directory (only files, not folders)
rclone lsf --files-only "$REMOTE_INPUT" | while read -r filename; do
  echo "$(date): Processing file: $filename"

  # Clear temp folder
  rm -f "$TMP_LOCAL"/*

  # Copy one file from remote input to temp
  rclone copy "$REMOTE_INPUT/$filename" "$TMP_LOCAL" --log-level INFO

  # Move the file to actual input folder
  mv "$TMP_LOCAL"/* "$LOCAL_DIR"/

  # Move the file from remote input to remote archive
  rclone moveto "$REMOTE_INPUT/$filename" "$REMOTE_ARCHIVE/$filename" --log-level INFO

  # Process only one file per run
  break
done
