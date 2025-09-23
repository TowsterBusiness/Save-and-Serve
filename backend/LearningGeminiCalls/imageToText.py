from google import genai
from PIL import Image
import json
import os


client = genai.Client(api_key=os.getenv("GoogleAPIKEY"))


def image_to_text(image_path):
    image = Image.open(image_path)
    
    prompt = """What items can you find in this fridge? List them in a comma separated list. 
    Do not give extra details, provide simple ingredients (Do not care for brands or types of items, just the item name). 
    For example, the following would work: Apple, Carrots, Ranch Dressing, Milk, Eggs, Bread, etc. 
    Every item you mention should be buyable from a grocery store. For example, do not look for leftovers or specific meals."""

    response = client.models.generate_content(
        model="gemini-2.5-flash-image-preview",
        contents=[prompt, image]
    )

    text = response.text
    with open("output.json", "w") as f:
        json.dump({"text": text}, f, indent=4)
    return text

image_to_text("LearningGeminiCalls\ImageOfFridge.jpg")