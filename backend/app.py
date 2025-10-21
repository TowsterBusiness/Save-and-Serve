from fastapi import FastAPI, UploadFile, File
import uvicorn
from CompletedRequests import recipieMaker
from dotenv import load_dotenv
import json
import os

load_dotenv("backend/example.env")

app = FastAPI()


def read_example_output() -> dict:
    sample_path = os.path.join(os.path.dirname(__file__), 'ExampleOutput.json')
    with open(sample_path, 'r', encoding='utf-8') as f:
        return json.load(f)


@app.get("/")
async def root():
    return {"message": "Hello Front End"}



@app.post("/testImagePassthrough")
async def testImagePassthrough(image: UploadFile = File(...)):
    # save image as file locally
    with open("backend/testImagePassthrough.jpg", "wb") as f:
        f.write(await image.read())
    return {"response": "Image saved successfully"}


@app.post("/getRecipies")
async def getRecipies(image: UploadFile = File(...)):
    Image = await image.read()
    print("Image received of size:", len(Image), "bytes")
    
    
    worker = recipieMaker()
    worker.getRecipies(Image)
    outputJSON = worker.outputJSON
    return {"response": outputJSON}

@app.post("/getRecipiesTest")
async def getRecipies(image: UploadFile = File(...)):
    Image = await image.read()
    print("Image received of size:", len(Image), "bytes")
    
    """Return sample output when running in DEV_MODE to make tests stable."""
    try:
        data = read_example_output()
        return data
    except FileNotFoundError:
        return {"error": "ExampleOutput.json not found"}
    except json.JSONDecodeError as e:
        return {"error": f"Failed to parse ExampleOutput.json: {e}"}



if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
    
    
    
    
    
    