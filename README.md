🛠️ Dependencies & Installation

This project uses a combination of Python scripts, shell scripts, and external tools for document parsing, OCR, LLM querying, and cloud sync. Below are all the dependencies and steps to install them.
📦 Python Dependencies

Install Python (version 3.8 or newer recommended), then install the required Python packages:

pip install whisper tika

Optional: If using virtualenv

python -m venv venv
source venv/bin/activate
pip install whisper tika

🧠 LLM (Ollama with Mistral)

The script llm_process.py depends on the Ollama runtime to locally run large language models.
Install Ollama:

curl -fsSL https://ollama.com/install.sh | sh

Pull the Mistral model:

ollama pull mistral

Make sure the ollama binary is located at /usr/local/bin/ollama or update OLLAMA_PATH in llm_process.py if it's elsewhere.
📄 Apache Tika (for PDF/Text Extraction)

The tika_extract.py script depends on the Java-based Tika server. It is automatically handled by the tika Python package.
Additional requirements:

    Java must be installed (Tika runs Java server in background)

sudo apt install default-jre  # or `brew install openjdk` on macOS

🧠 Whisper (for OCR/audio transcription)

The whisper_ocr.py script uses OpenAI's Whisper model.

pip install git+https://github.com/openai/whisper.git

Note: Whisper also requires ffmpeg to be installed:

sudo apt install ffmpeg  # Debian/Ubuntu
# or
brew install ffmpeg      # macOS

☁️ Rclone (Cloud Sync)

Used in rclone_one_by_one_sync.sh to sync files with cloud storage (e.g., Google Drive, S3, etc.)
Install:

curl https://rclone.org/install.sh | sudo bash

You’ll need to configure it:

rclone config

🔁 Other Shell Scripts

Scripts like process.sh and watcher.sh assume a standard Linux environment with:

    bash

    inotifywait (for filesystem watching)

Install inotify-tools if needed:

sudo apt install inotify-tools

📂 Setting Up Output Directories

Before running the scripts, ensure you have the following output directories:

mkdir -p output/ocr_output
mkdir -p output/llm_output

These will store:

    ocr_output: Raw text extracted via Whisper or Tika

    llm_output: JSON-formatted output from the LLM (Ollama)

✏️ Modify Script Output Paths

Update the scripts to write their output to these new directories.
tika_extract.py

Replace this line:

output_file = f"/home/server-admin/document_pipeline/ocr_output/raw_{base_name}_{timestamp}.txt"

With:

output_file = f"output/ocr_output/raw_{base_name}_{timestamp}.txt"

llm_process.py

Ensure you're passing an output path like this (next section shows how to run it):

python llm_process.py path/to/input.txt output/llm_output/output.json

whisper_ocr.py

Use this format when running:

python whisper_ocr.py path/to/audio.mp3 output/ocr_output/audio_transcription.txt

🚀 Running the Scripts
1. Run Tika-based OCR on PDFs or documents

python tika_extract.py path/to/document.pdf

This will save a raw .txt output in output/ocr_output/.
2. Run Whisper OCR on audio

python whisper_ocr.py path/to/audio.mp3 output/ocr_output/audio_transcription.txt

3. Run LLM extraction

python llm_process.py output/ocr_output/raw_file.txt output/llm_output/structured.json

This uses the OCR output as input and writes JSON-structured data to llm_output.

✏️ Customizing the LLM Prompt

The prompt used for extracting data is hardcoded in llm_process.py. You can easily edit it to extract different fields or change the response format.
🔍 How to Edit

Open llm_process.py and locate this block (around the middle of the script):

prompt = f"""
Extract the following fields from the text:
- Invoice Number
- Date
- Total Amount

Text:
{input_text}

Format the response in JSON only, no extra text.
Example: 
{{ "invoice_number": "INV-1234", "date": "2025-06-11", "total_amount": "549.98" }}
"""

🛠️ Customize It

Change the list of fields or output format to suit your document type.
For example, to extract Client Name and Due Date, modify it like this:

prompt = f"""
Extract the following fields from the text:
- Client Name
- Due Date

Text:
{input_text}

Format the response in JSON only.
Example: 
{{ "client_name": "Acme Corp", "due_date": "2025-07-01" }}
"""

