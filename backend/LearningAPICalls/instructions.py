import json

with open("instructions.json", "r") as f:
    data = json.load(f)

dataCollected = []
steps = data[0]["steps"]
for step in steps:
    dataCollected.append(step["step"])

print(json.dumps(dataCollected, indent=4))