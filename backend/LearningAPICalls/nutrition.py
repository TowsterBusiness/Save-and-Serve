import json

with open("nutrition.json", "r") as f:
    data = json.load(f)

dataCollected = []

dataCollected.append({
    "calories": data["calories"],
    "fat": data["fat"],
    "protein": data["protein"],
    "carbohydrates": data["carbs"]
})

print(json.dumps(dataCollected, indent=4))