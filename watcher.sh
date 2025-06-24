#!/bin/bash
set -x
# Directory to monitor
INPUT_DIR="/home/server-admin/document_pipeline/input"

# Log file
LOG_FILE="/home/server-admin/document_pipeline/logs/watcher.log"

# Ensure log directory exists
mkdir -p /home/server-admin/document_pipeline/logs

# Start watching the directory
while true; do
    # Wait for a new .pdf file to be closed (finished uploading)
    FILE=$(inotifywait -e close_write,moved_to --format '%f' "$INPUT_DIR" | grep '\.pdf$')
    
    if [[ $FILE ]]; then
        # Log the event
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Detected new file: $FILE" >> "$LOG_FILE"
        
        # Trigger the processing script
        /home/server-admin/document_pipeline/scripts/process.sh "$INPUT_DIR/$FILE"
        
        # Log completion
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Processing completed for $FILE" >> "$LOG_FILE"
    fi
done
