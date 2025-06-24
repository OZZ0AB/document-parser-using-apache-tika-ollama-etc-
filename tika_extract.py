from tika import parser
import sys
import logging
import os
import datetime

# Set up logging
logging.basicConfig(level=logging.INFO)

def extract_raw_text(file_path):
    try:
        # Force Tika to return raw content (no filtering)
        raw = parser.from_file(file_path, xmlContent=False)  # xmlContent=False returns plain text
        return raw['content']
    except Exception as e:
        logging.error(f"Tika error: {e}")
        return ""

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python tika_extract.py <input_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    base_name = os.path.splitext(os.path.basename(input_file))[0]
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    output_file = f"/home/server-admin/document_pipeline/ocr_output/raw_{base_name}_{timestamp}.txt"

    logging.info(f"Extracting raw text from: {input_file}")

    raw_text = extract_raw_text(input_file)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(raw_text)
    
    logging.info(f"Raw text saved to: {output_file}")