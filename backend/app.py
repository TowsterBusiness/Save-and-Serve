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
