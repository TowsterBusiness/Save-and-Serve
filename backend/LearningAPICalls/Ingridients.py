import json
from fractions import Fraction

with open("ingridients.json", "r") as f:
    data = json.load(f)


dataCollected = []

for recipe in data:
    id =recipe['id']
    title = recipe['title']
    image = recipe['image']
    missedIngredients= recipe['missedIngredientCount']

    usedIngredients = recipe['usedIngredients']
    ingridentsList = []
    for ingrident in usedIngredients:
        
        ofIncluded = " of "
        amount = ingrident['amount']
        
        if ingrident['unitLong'] =="":
            ofIncluded = ""
            
            #Check for decimals below 1, and replace with fractions
            
            if ingrident['amount'] < 1:
                # Convert to fraction
                fraction = Fraction(ingrident['amount']).limit_denominator()
                amount = f"{fraction.numerator}/{fraction.denominator}"
                
        ingridentsList.append(f"{amount} {ingrident['unitLong']}{ofIncluded}{ingrident['name']}")

    dataCollected.append({
        "id": id,
        "title": title,
        "image": image,
        "missedIngredients": missedIngredients,
        "usedIngredients": ingridentsList
    })

print(json.dumps(dataCollected, indent=4))