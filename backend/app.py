from dotenv import load_dotenv
from fastapi import FastAPI, UploadFile, File
import uvicorn
from CompletedRequests import superAccurateRecipieMaker
import json
import os
import vertexai
from vertexai.generative_models import GenerativeModel
import pathlib

app = FastAPI()

print("Booting up, using credentials from Render secret file")

key_path = "/etc/secrets/gcp_key.json"
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = key_path

if pathlib.Path(key_path).exists():
    print("Credentials file found at:", key_path)
else:
    raise FileNotFoundError(f"Credentials file not found at {key_path}")

print("Credentials file path:", os.environ["GOOGLE_APPLICATION_CREDENTIALS"])


project_id = os.getenv("googleProjectID")
location = "us-central1"

vertexai.init(project=project_id, location=location)
model = GenerativeModel("gemini-2.5-flash-lite")


def read_example_output() -> dict:
    sample_path = os.path.join(os.path.dirname(__file__), 'ExampleOutput.json')
    with open(sample_path, 'r', encoding='utf-8') as f:
        return json.load(f)


@app.get("/")
async def root():
    return {"message": "Hello Front End"}



# @app.post("/getRecipies")
# async def getRecipies(image: UploadFile = File(...)):
#     Image = await image.read()
#     print("Image received of size:", len(Image), "bytes")
    
    
#     worker = recipieMaker()
#     worker.getRecipies(Image)
#     outputJSON = worker.outputJSON
#     return {"response": outputJSON}


@app.post("/getRecipies")
# I want input parameter to bea json object
async def getRecipies(Ingredients: dict):

    listOfIngridients = Ingredients['ingredients']
    print("Ingredients received:", listOfIngridients)
    
    worker = superAccurateRecipieMaker(model)
    worker.getRecipies(listOfIngridients)
    outputJSON = worker.outputJSON
    return {"response": outputJSON}


@app.post("/getIngredients")
async def getIngredients(image: UploadFile = File(...)):
    Image = await image.read()
    print("Image received of size:", len(Image), "bytes")
    worker = superAccurateRecipieMaker(model)
    ingridents = worker.getIngridents(Image)
    return {"response": ingridents}




@app.post("/testgetRecipies")
async def testgetRecipies(Ingredients: dict):
    """Return sample output when running in DEV_MODE to make tests stable."""
    try:
        data = read_example_output()
        return {"response": data}
    except FileNotFoundError:
        return {"error": "ExampleOutput.json not found"}
    except json.JSONDecodeError as e:
        return {"error": f"Failed to parse ExampleOutput.json: {e}"}
    
    


@app.post("/testgetIngredients")
async def testgetIngredients(image: UploadFile = File(...)):
    Image = await image.read()
    print("Image received of size:", len(Image), "bytes")
    
    return {"response": "Jam, Dressing, Mustard, Salsa, Pickles, Maple Syrup, Yogurt, Milk, Creamer, Hummus, Eggs, Strawberries, Blueberries, Bell Peppers, Carrots, Oranges, Apples, Lettuce, Spinach, Deli Meat, Cheese, Butter, Bread, Juice, Water, Hot Sauce, Ketchup, Mayonnaise, Lemon Juice, Limes, Olives, Pesto, Soy Sauce, Tortillas, Sliced Cheese, Fruit Preserves"}



@app.post("/testImagePassthrough")
async def testImagePassthrough(image: UploadFile = File(...)):
    # save image as file locally
    with open("backend/testImagePassthrough.jpg", "wb") as f:
        f.write(await image.read())
    return {"response": "Image saved successfully"}




if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)