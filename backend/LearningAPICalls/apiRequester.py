import requests

url = "https://api.spoonacular.com/recipes/642582/priceBreakdownWidget.json"
headers = {"Content Type": "application/json"}

ingridients = "chicken breast, ground beef, eggs, tofu, canned tuna, chickpeas, bacon, rice, pasta, bread, tortillas, potatoes, quinoa, onions, garlic, bell peppers, carrots, spinach, tomatoes, broccoli, apples, bananas, lemons, avocados, cheese, milk, olive oil, salt, black pepper, paprika"
default_params = {
    "apiKey":  "65ed94ce760342f5bdb12f4757f2db94",
}


# findbyIngredients
"""
params ={
    "ingredients":ingridients,
    "number":5,
    "ranking":2,
    "ignorePantry":True,
    **default_params
}
"""
# analyzedInstructions


# params ={
#     "stepBreakdown":True,
#     **default_params
# }


# nutritionWidget and priceBreakdownWidget

params ={
    **default_params
}

response = requests.get(url,  headers = headers, params=params)
print(response.status_code)

import json

with open("price.json", "w") as f:
    json.dump(response.json(), f)