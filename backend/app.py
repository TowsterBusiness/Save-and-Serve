from fastapi import FastAPI, UploadFile, File
from pydantic import BaseModel
from venv import create
import PIL
import uvicorn
from CompletedRequests import recipieMaker
from dotenv import load_dotenv
import json
import os

load_dotenv()

app = FastAPI()

def read_example_output() -> dict:
    sample_path = os.path.join(os.path.dirname(__file__), 'ExampleOutput.json')
    with open(sample_path, 'r', encoding='utf-8') as f:
        return json.load(f)


@app.get("/")
async def root():
    return {"message": "Hello Front End"}


@app.post("/getRecipies")
async def getRecipies(image: UploadFile = File(...)):
    worker = recipieMaker()
    contents = await image.read()
    worker.getRecipies(contents)
    outputJSON = worker.outputJSON
    return {"response": outputJSON}



@app.get("/test")
async def test(image: bytes | None = None):
    """Return sample output when running in DEV_MODE to make tests stable."""
    try:
        data = read_example_output()
        return data
    except FileNotFoundError:
        return {"error": "ExampleOutput.json not found"}
    except json.JSONDecodeError as e:
        return {"error": f"Failed to parse ExampleOutput.json: {e}"}
    


@app.post("/getResponseJSON")
async def getResponseJSON():
    with open("ExampleOutput.json", "r") as f:
        outputJSON = f.read()
    return {"response": outputJSON}

@app.post("/sendImageBinary")
async def sendImageBinary(image: bytes):
    #create a PIL image and check if succesfully made, return boolean
    try:
        img = PIL.Image.open(image)
        worked = True
    except:
        worked = False
    
    return {"response": worked}



if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)