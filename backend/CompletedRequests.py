import json
from fractions import Fraction
import requests
from google import genai
from PIL import Image
import json
import os
from serpapi import GoogleSearch

class recipieMaker():
    
    def __init__(self):
        self.geminiClient = genai.Client(api_key=os.getenv("GoogleAPIKEY"))
        
        self.headers = {"Content-Type": "application/json"}
        self.default_params = {"apiKey":  os.getenv("SpoonacularAPIKEY")}

    def image_to_text(self, image):
        
        prompt = """What items can you find in this fridge? List them in a comma separated list. 
        Do not give extra details, provide simple ingredients (Do not care for brands or types of items, just the item name). 
        For example, the following would work: Apple, Carrots, Ranch Dressing, Milk, Eggs, Bread, etc. 
        Every item you mention should be buyable from a grocery store. For example, do not look for leftovers or specific meals."""

        response = self.geminiClient.models.generate_content(
            model="gemini-2.5-flash-image-preview",
            contents=[prompt, image]
        )

        text = response.text
        with open("output.json", "w") as f:
            json.dump({"text": text}, f, indent=4)
        return text
    
    def processBinaryImage(self, imageInBinary = None):
        return Image.open(imageInBinary)
        # return Image.open("LearningGeminiCalls\ImageOfFridge.jpg") # PIL IMAGE
    
    def getRecipiesMatchingIngridents(self):
        
        self.outputJSON = [{} for i in range(len(self.recipiesAPIFOUND))]

        for i, recipe in enumerate(self.recipiesAPIFOUND):

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

            self.outputJSON[i]["GeneralInfo"]={
                "id": id,
                "title": title,
                "image": image,
                "missedIngredients": missedIngredients,
                "usedIngredients": ingridentsList
            }

    
    def getSpecificsOnRecipies(self):
        for i, recipie in enumerate(self.outputJSON):

            id = recipie["GeneralInfo"]["id"]
            
            instructions = requests.get(f"https://api.spoonacular.com/recipes/{id}/analyzedInstructions",  headers = self.headers, params={"stepBreakdown":True,**self.default_params}).json()
            if instructions == []:
                self.outputJSON[i]["instructions"] = []
                continue
            steps = instructions[0]["steps"]

            justInstructions = []

            for step in steps:
                justInstructions.append(step["step"])
            self.outputJSON[i]["instructions"] = justInstructions

            nutrition =  requests.get(f"https://api.spoonacular.com/recipes/{id}/nutritionWidget.json",  headers = self.headers, params={**self.default_params}).json()

            self.outputJSON[i]["nutrition"] = {
                "calories": nutrition["calories"],
                "fat": nutrition["fat"],
                "protein": nutrition["protein"],
                "carbohydrates": nutrition["carbs"]
            }

            price_data = requests.get(f"https://api.spoonacular.com/recipes/{id}/priceBreakdownWidget.json",  headers = self.headers, params={**self.default_params}).json()

            price = price_data["totalCost"]/100

            self.outputJSON[i]["price"] = price

        print(json.dumps(self.outputJSON, indent=4))
    
    
    def getRecipies(self, imageInBinary = None):
        image = self.processBinaryImage(imageInBinary)
        print("Image Processed")

        ingredients = self.image_to_text(image)

        # ingredients = "Ketchup, Jam, Mustard, Salad Dressing, Salsa, Milk, Yogurt, Bagels, Grapes, Strawberries, Blueberries, Lettuce, Tomatoes, Peppers, Eggs, Cheese, Tofu, Chocolate Syrup, Hummus, Chips, Butter, Orange Juice, Water Bottles"
        print(f"Ingridients are: {ingredients}")
        
        ingredientsparams ={
            "ingredients":ingredients,
            "number":2,
            "ranking":2,
            "ignorePantry":True,
            **self.default_params
        }

        self.recipiesAPIFOUND = requests.get(f"https://api.spoonacular.com/recipes/findByIngredients",  headers = self.headers, params=ingredientsparams).json()
        
        
        self.getRecipiesMatchingIngridents()
        self.getSpecificsOnRecipies()
        # self.replaceImageWithURL()
        
    def replaceImageWithURL(self):
        for i, recipie in enumerate(self.outputJSON):
            title = recipie["GeneralInfo"]["title"]
            imageURL = self.getImageURL(title + " food")
            if imageURL:
                self.outputJSON[i]["GeneralInfo"]["image"] = imageURL
        
    def getImageURL(self, query):
        params = {
            "engine": "google_images_light",
            "q": query, 
            "api_key": os.getenv("SERPAPI_KEY")
        }

        search = GoogleSearch(params)
        results = search.get_dict()
        
        images_results = results.get("images_results", [])
        if images_results:
            return images_results[0].get("original")  # first image URL
        return None
        


# worker = recipieMaker()
# worker.getRecipies()
# print(worker.outputJSON)