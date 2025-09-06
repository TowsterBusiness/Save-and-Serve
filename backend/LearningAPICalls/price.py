import json

with open("price.json", "r") as f:
    data = json.load(f)

price = data["totalCost"]/100

print(json.dumps(price))