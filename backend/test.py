import requests

ingredientsList = {"ingredients": []}

def getIngredients():
    with open("Images/IMG_9248.JPG", "rb") as image:
        files = {'image': ('ImageOfFridge.jpg', image, 'image/jpeg')}
        
        results =  requests.post("https://saveyourfridge-backend.onrender.com/getIngredients", files=files)
        print("Ingredients received:", results.json()['response'])
        return results

response = getIngredients()
ingredientsList["ingredients"].append(response.json()['response'])

# response = getIngredients()
# ingredientsList["ingridients"].append(response.json()['response'])


# do this call once ready for recipies
response = requests.post("https://saveyourfridge-backend.onrender.com/getRecipies", json=ingredientsList)
print(response.text)

# response = requests.post("https://saveyourfridge-backend.onrender.com/getRecipies", data = response)
# print(response.json())