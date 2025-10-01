from fastapi import FastAPI
from pydantic import BaseModel
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


@app.get("/getRecipies")
async def getRecipies(image: bytes):
    worker = recipieMaker()
    worker.getRecipies(image)
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