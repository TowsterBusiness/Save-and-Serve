
# call locally hosted api with the function /test
from regex import F
import requests

with open("ImageOfFridge.jpg", "rb") as image:

    files = {'image': ('ImageOfFridge.jpg', image, 'image/jpeg')}


    # do this call as many times as needed
    ingredients = requests.post("http://localhost:8000/testgetIngredients", files=files)
    print(ingredients.json())



# do this call once ready for recipies
response = requests.post("http://localhost:8000/testgetRecipies", json=ingredients.json())
print(response.text)

# response = requests.post("https://saveyourfridge-backend.onrender.com/getRecipies", data = response)
# print(response.json())