
# call locally hosted api with the function /test
from regex import F
import requests

with open("backend/ImageOfFridge.jpg", "rb") as image:

    files = {'image': ('ImageOfFridge.jpg', image, 'image/jpeg')}
    
    response = requests.post("http://localhost:8000/getRecipies", files=files)
    print(response.json())
