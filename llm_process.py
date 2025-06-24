import sys
import subprocess
import logging

logging.basicConfig(level=logging.INFO)

OLLAMA_PATH = "/usr/local/bin/ollama"

def query_llm(prompt):
    try:
        cmd = [OLLAMA_PATH, "run", "mistral"]
        process = subprocess.Popen(
            cmd,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        response, error = process.communicate(input=prompt)
        if error:
            logging.error(f"LLM Error: {error}")
            return ""
        return response.strip()
    except Exception as e:
        logging.error(f"LLM Exception: {e}")
        return ""

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python llm_process.py <input_file> <output_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    llm_output_file = sys.argv[2]  # Will be in llm_output/

    try:
        with open(input_file, 'r') as f:
            input_text = f.read().strip()

        if not input_text:
            logging.warning("Input text is empty. Skipping LLM processing.")
            sys.exit(0)

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
        
        result = query_llm(prompt)

        if result:
            with open(llm_output_file, 'w') as f:
                f.write(result)
            logging.info(f"LLM Output saved to {llm_output_file}")
        else:
            logging.warning("No response from LLM.")
    except Exception as e:
        logging.error(f"LLM Processing Error: {e}")
