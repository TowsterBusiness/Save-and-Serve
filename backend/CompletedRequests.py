import json
from fractions import Fraction
import requests


ingredients = "chicken breast, ground beef, salmon fillet, shrimp, bacon, eggs, milk, cheddar cheese, mozzarella cheese, butter, olive oil, flour, sugar, rice, pasta, potatoes, onions, garlic, tomatoes, spinach, broccoli, carrots, bell pepper, mushrooms, lettuce, cucumber, lemon, lime, soy sauce, honey, peanut butter"


headers = {"Content Type": "application/json"}
default_params = {
    "apiKey":  "65ed94ce760342f5bdb12f4757f2db94",
}

ingredientsparams ={
    "ingredients":ingredients,
    "number":2,
    "ranking":2,
    "ignorePantry":True,
    **default_params
}

data = requests.get(f"https://api.spoonacular.com/recipes/findByIngredients",  headers = headers, params=ingredientsparams).json()

Data = [{} for i in range(len(data))]

for i, recipe in enumerate(data):

    id = recipe['id']
    title = recipe['title']
    image = recipe['image']
    missedIngredients = recipe['missedIngredientCount']

    usedIngredients = recipe['usedIngredients']
    ingridentsList = []
    for ingrident in usedIngredients:

        ofIncluded = " of "
        amount = ingrident['amount']

        if ingrident['unitLong'] == "":
            ofIncluded = ""
                
            #Check for decimals below 1, and replace with fractions
                
            if ingrident['amount'] < 1:
                # Convert to fraction
                fraction = Fraction(ingrident['amount']).limit_denominator()
                amount = f"{fraction.numerator}/{fraction.denominator}"

        ingridentsList.append(f"{amount} {ingrident['unitLong']}{ofIncluded}{ingrident['name']}")

    Data[i]["GeneralInfo"]={
        "id": id,
        "title": title,
        "image": image,
        "missedIngredients": missedIngredients,
        "usedIngredients": ingridentsList
    }

for i, recipie in enumerate(Data):

    id = recipie["GeneralInfo"]["id"]
    
    instructions = requests.get(f"https://api.spoonacular.com/recipes/{id}/analyzedInstructions",  headers = headers, params={"stepBreakdown":True,**default_params}).json()

    steps = instructions[0]["steps"]

    justInstructions = []

    for step in steps:
        justInstructions.append(step["step"])
    Data[i]["instructions"] = justInstructions


    nutrition =  requests.get(f"https://api.spoonacular.com/recipes/{id}/nutritionWidget.json",  headers = headers, params={**default_params}).json()

    Data[i]["nutrition"] = {
        "calories": nutrition["calories"],
        "fat": nutrition["fat"],
        "protein": nutrition["protein"],
        "carbohydrates": nutrition["carbs"]
    }

    price_data = requests.get(f"https://api.spoonacular.com/recipes/{id}/priceBreakdownWidget.json",  headers = headers, params={**default_params}).json()

    price = price_data["totalCost"]/100

    Data[i]["price"] = price

with open("ExampleOutput.json", "w") as f:
    json.dump(Data, f, indent=4)
    
print(json.dumps(Data, indent=4))