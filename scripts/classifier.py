import os
from PIL import Image
from kraken import rpred
from kraken.lib import models

# --- Configuration ---
MODEL_PATH = 'path/to/your/akkadian_model.mlmodel'
AKKADIAN_DIR = 'test_akkadian'
ENGLISH_DIR = 'test_english'
# -------------------

print("Loading model...")
model = models.load_any(MODEL_PATH)

def get_avg_confidence(image_path):
    """Runs OCR on an image and returns the average character confidence."""
    try:
        im = Image.open(image_path)
        # Use rpred for recognition predicate
        # The 'level' parameter can be 'line' or 'char' - we want char for confidence
        predictions = list(rpred.rpred(model, im, level='char'))

        if not predictions:
            return 0.0

        # Each prediction is a tuple: (character, start_pos, end_pos, confidence_score)
        confidences = [pred[3] for pred in predictions]
        return sum(confidences) / len(confidences)

    except Exception as e:
        print(f"Could not process {image_path}: {e}")
        return 0.0

    print("\n--- Testing on Akkadian Images ---")
    for filename in os.listdir(AKKADIAN_DIR):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.tif')):
            path = os.path.join(AKKADIAN_DIR, filename)
            avg_conf = get_avg_confidence(path)
            print(f"{filename}: Average Confidence = {avg_conf:.4f}")

    print("\n--- Testing on English Images ---")
    for filename in os.listdir(ENGLISH_DIR):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.tif')):
            path = os.path.join(ENGLISH_DIR, filename)
            avg_conf = get_avg_confidence(path)
            print(f"{filename}: Average Confidence = {avg_conf:.4f}")
        
def classify_line(line_image_pil):
    """
    Classifies a PIL image of a text line as 'Akkadian' or 'English'.

    Args:
        line_image_pil (PIL.Image.Image): A cropped image of a single text line.

    Returns:
        str: 'Akkadian' or 'English'.
    """
    try:
        # Get character-level predictions with confidences
        predictions = list(rpred.rpred(AKKADIAN_MODEL, line_image_pil, level='char'))

        if not predictions:
            return 'English' # Treat empty lines as English/non-Akkadian

        # Calculate average confidence
        confidences = [pred[3] for pred in predictions]
        avg_confidence = sum(confidences) / len(confidences)

        # Apply the threshold
        if avg_confidence >= CONFIDENCE_THRESHOLD:
            return 'Akkadian'
        else:
            return 'English'
            
    except Exception:
        # If anything goes wrong during prediction, default to English
        return 'English'

# --- Example Usage ---
# In your main pipeline script, you would do this for each line:
#
# from PIL import Image
#
# # Assume `line_bbox` contains the coordinates [x1, y1, x2, y2]
# # and `full_page_image` is the full page as a PIL Image object
# cropped_line = full_page_image.crop(line_bbox)
#
# language_label = classify_line(cropped_line)
# print(f"This line is classified as: {language_label}")

curl -L https://www.kaggle.com/api/v1/datasets/download/senju14/ocr-dataset-of-multi-type-documents