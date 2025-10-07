from venv import create
import PIL
from fastapi import FastAPI
import uvicorn
from CompletedRequests import recipieMaker

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello Front End"}

 
@app.post("/getRecipies")
async def getRecipies(image: bytes):
    
    worker = recipieMaker()
    worker.getRecipies(image)
    outputJSON = worker.outputJSON
    return {"response": outputJSON}


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