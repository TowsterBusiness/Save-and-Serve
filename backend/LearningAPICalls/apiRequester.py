import os
import requests
import dotenv

dotenv.load_dotenv("backend/example.env")

# Search Recipes by Ingredients endpoint
url = "https://api.spoonacular.com/recipes/findByIngredients"
headers = {"Content-Type": "application/json"}

ingrideints = "chicken breast, ground beef, eggs, tofu, canned tuna, chickpeas, bacon, rice, pasta, bread, tortillas, potatoes, quinoa, onions, garlic, bell peppers, carrots, spinach, tomatoes, broccoli, apples, bananas, lemons, avocados, cheese, milk, olive oil, salt, black pepper, paprika"
default_params = {
    "apiKey": os.getenv("SPOONACULAR_KEY"),
}


# findbyIngredients

params ={
    "ingredients":ingrideints,
    "number":2,
    "ranking":1,
    "ignorePantry":True, # TODO Might be the issue we dont get many back
    **default_params
}

# analyzedInstructions


# params ={
#     "stepBreakdown":True,
#     **default_params
# }


# nutritionWidget and priceBreakdownWidget

# params ={
#     **default_params
# }

response = requests.get(url,  headers = headers, params=params)
print(response.status_code)

import json

# Save the recipes response
with open("recipes.json", "w") as f:
    json.dump(response.json(), f, indent=2)

print(f"Found {len(response.json())} recipes")
if response.json():
    print(f"First recipe: {response.json()}")
