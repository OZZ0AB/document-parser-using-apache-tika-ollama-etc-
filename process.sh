#!/bin/bash

# Input file path (passed as argument)
INPUT_FILE="$1"
BASE_NAME=$(basename "$INPUT_FILE" | cut -d. -f1)

# Output paths
OCR_OUTPUT="/home/server-admin/document_pipeline/ocr_output/ocr_${BASE_NAME}_$(date +%s).txt"
LLM_OUTPUT="/home/server-admin/document_pipeline/llm_output/llm_${BASE_NAME}_$(date +%s).txt"

# Log file
LOG_FILE="/home/server-admin/document_pipeline/logs/processor.log"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Processing $INPUT_FILE" >> "$LOG_FILE"

# Step 1: Run Tika to extract raw text
RAW_OCR="/home/server-admin/document_pipeline/ocr_output/raw_$(basename "$INPUT_FILE" .pdf)_$(date +%Y%m%d_%H%M%S).txt"
python ~/document_pipeline/scripts/tika_extract.py "$INPUT_FILE" "$RAW_OCR" >> "$LOG_FILE" 2>&1

# Step 2: If Tika fails, use Tesseract OCR
TIKA_TEXT=$(cat "$OCR_OUTPUT" 2>/dev/null)
if [ -z "$TIKA_TEXT" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Tika failed. Using Tesseract..." >> "$LOG_FILE"
    
    # Convert PDF to images
    pdftoppm -png -r 300 "$INPUT_FILE" /tmp/page
    # Run OCR on first page
    tesseract /tmp/page-1.png "$OCR_OUTPUT" >> "$LOG_FILE" 2>&1
    rm -f /tmp/page-*.png
fi

# Step 3: Run LLM on OCR output
python3 ~/document_pipeline/scripts/llm_process.py "$OCR_OUTPUT" "$LLM_OUTPUT" >> "$LOG_FILE" 2>&1

# Clean up
rm -f temp.txt