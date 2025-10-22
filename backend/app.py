from dotenv import load_dotenv
from fastapi import FastAPI, UploadFile, File
import uvicorn
from CompletedRequests import recipieMaker
import json
import os
load_dotenv("example.env")

app = FastAPI()


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

    listOfIngridients = Ingredients['ingridients']
    print("Ingredients received:", listOfIngridients)
    
    worker = recipieMaker()
    worker.getRecipies(listOfIngridients)
    outputJSON = worker.outputJSON
    return {"response": outputJSON}


@app.post("/getIngredients")
async def getIngredients(image: UploadFile = File(...)):
    Image = await image.read()
    print("Image received of size:", len(Image), "bytes")
    
    worker = recipieMaker()
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