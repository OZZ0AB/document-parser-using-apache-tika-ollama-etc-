import whisper
import sys

def perform_ocr(audio_path):
    model = whisper.load_model("medium")
    result = model.transcribe(audio_path)
    return result["text"]

if __name__ == "__main__":
    ocr_text = perform_ocr(sys.argv[1])
    with open(sys.argv[2], 'w') as f:
        f.write(ocr_text)
